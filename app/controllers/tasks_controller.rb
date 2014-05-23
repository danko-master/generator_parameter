# require "redis"

class TasksController < ApplicationController
  def index
    respond_to do |format|
      format.html { get_index_data }
      # format.xml  { render :xml => get_index_data_for_xml }
      format.xml  { send_data(get_index_data_for_xml, :filename => "param_val_generator_#{Time.now.to_i}.xml", :type => "text/xml") }
    end     
  end

  # def new
  #   @param_val = ParamVal.new
  # end

  def create   
    date_start = Date.parse(params["date_start"])
    date_end = Date.parse(params["date_end"])
    
    Redis.current.flushdb
    redis = Redis.new

    if params["function_type"] == "ustavki"
      set_data_ustavki(redis, params, date_start, date_end)
    elsif params["function_type"] == "lineal"
      set_data_lineal(redis, params, date_start, date_end)
    end
    redis.hmset "tmp_data_params", "date_start", params["date_start"], "date_end", params["date_end"], "parameter_id", params["parameter"].to_i, "subject_id", params["subject"].to_i, "function_type", params["function_type"], 'dispersion', params["dispersion"], "above_top", params["above_top"], "below_bottom", params["below_bottom"],"lineal_k", params["lineal_k"], "lineal_b", params["lineal_b"]
    flash.now[:success] =  "Успешно сформированы данные"
    get_index_data
    # redirect_to informations_path
  end

  def destroy_all_tmp
    Redis.current.flushdb
    flash.now[:error] =  "Успешно удалено"
    # redirect_to informations_path
  end

  def save_all_tmp
    records = Redis.current.keys("param_val:*")
    if records.present?
      records.each do |item|
        pv = ParamVal.new()
        pv.parameter_id = Redis.current.hget(item, "parameter_id")
        pv.subject_id = Redis.current.hget(item, "subject_id")
        pv.date_time = Redis.current.hget(item, "date_time")
        pv.val_numeric = Redis.current.hget(item, "val_numeric")
        pv.created_at = Time.now()
        pv.updated_at = Time.now()
        pv.val_string = "from_generator"
        pv.save
      end
    end

    Redis.current.flushdb
    flash[:success] =  "Успешно сохранено в базу"
    redirect_to informations_path
  end
  
  private

  def insert_dispersion(y, dispersion)
    action_sign = rand(2)
    dispersion = rand(dispersion/2 + 1)
    if action_sign.to_i > 0
      y = y + dispersion
    else
      y = y - dispersion
    end
  end

  def insert_dispersion_for_up(y, dispersion)
    dispersion = rand(dispersion)
    y = y - dispersion
  end

  def insert_dispersion_for_down(y, dispersion)
    dispersion = rand(dispersion)
    y = y + dispersion
  end

  def set_data_ustavki(redis, params, date_start, date_end)
    presets = ParamPreset.where("date_time >= ?", date_start).where("date_time <= ?", date_end).where(parameter_id: params["parameter"].to_i).where(subject_id: params["subject"].to_i)
    presets.each do |preset|
      if preset.up_preset.present? && preset.down_preset.present?
        a = preset.up_preset
        a = a + params["dispersion"].to_i if params["above_top"].present?

        b = preset.down_preset
        b = b - params["dispersion"].to_i if params["below_bottom"].present?

        y = (a..b).to_a.sample
      elsif preset.up_preset.present?
        y = preset.up_preset
        if params["above_top"].present?
          y = insert_dispersion(y, params["dispersion"].to_i)
        else
          y = insert_dispersion_for_up(y, params["dispersion"].to_i)
        end
      elsif preset.down_preset.present?
        y = preset.down_preset
        if params["below_bottom"].present?
          y = insert_dispersion(y, params["dispersion"].to_i)
        else
          y = insert_dispersion_for_down(y, params["dispersion"].to_i)
        end
      else
        return nil
      end        
        
      redis.hmset "param_val:#{preset.id}", "date_time", preset.date_time, "val_numeric", y, "parameter_id", params["parameter"].to_i, "subject_id", params["subject"].to_i, "formula_type", "по уставкам", "preset_down_preset", preset.down_preset, "preset_up_preset", preset.up_preset
    end
  end

  def set_data_lineal(redis, params, date_start, date_end)  
    x = 1 
    while date_start < date_end do           
      y = params["lineal_k"].to_i*x + params["lineal_b"].to_i
      y = insert_dispersion(y, params["dispersion"].to_i)
      redis.hmset "param_val:#{x}", "date_time", date_start, "val_numeric", y, "parameter_id", params["parameter"].to_i, "subject_id", params["subject"].to_i, "formula_type", "y=kx+b"
      date_start = date_start + params["periodicity"].to_i
      x += 1
    end
  end

  def get_index_data
    @tmp_data = Redis.current.keys("param_val:*").sort {|a,b| b.split(":")[1].to_i <=> a.split(":")[1].to_i}
    @tmp_data_params = Redis.current.hgetall("tmp_data_params")
  end

  def get_index_data_for_xml
    get_index_data
    redis_data = @tmp_data
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.root {
        xml.system_source "local system generator"
        xml.date_time Time.now
        xml.establishment "Test establishment"
        xml.establishment_kladr nil
        xml.establishment_address "Крымский мост, д.1"
        
        redis_data.each do |item|
          xml.param_val {
            xml.id item.to_s.split(":")[1]
            xml.parent_id nil
              parameter = Parameter.find(Redis.current.hget(item, "parameter_id"))
            xml.name (parameter.present? ? parameter.name : nil)
            xml.val_numeric Redis.current.hget(item, "val_numeric")
            xml.val_string "from_generator_xml"
              subject = Subject.find(Redis.current.hget(item, "subject_id"))
            xml.subject_name (subject.present? ? subject.name : nil)
            xml.subject_kladr (subject.present? ? subject.kladr.first.code : nil)
            xml.subject_address nil
            xml.description nil
            xml.date_time Date.parse(Redis.current.hget(item, "date_time"))
            xml.status nil
            if Redis.current.hget(item, "formula_type") == "по уставкам"
              xml.ustavka_value_bottom Redis.current.hget(item, "preset_down_preset")
              xml.ustavka_value_bottom_warning nil
              xml.ustavka_value_top Redis.current.hget(item, "preset_up_preset")
              xml.ustavka_value_top_warning nil
              xml.ustavka_type nil
            else
              xml.ustavka_value_bottom nil
              xml.ustavka_value_bottom_warning nil
              xml.ustavka_value_top nil
              xml.ustavka_value_top_warning nil
              xml.ustavka_type nil
            end
            xml.sub_param_val nil
          }
        end          
        
      }      
    end
    builder.to_xml
  end
end
