require "redis"

class InformationsController < ApplicationController
  def index
    @tmp_data = Redis.current.keys("param_val:*")
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
    
    flash[:success] =  "Успешно сформированы данные"
    redirect_to informations_path
  end

  def destroy_all_tmp
    Redis.current.flushdb
    flash[:error] =  "Успешно удалено"
    redirect_to informations_path
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
        
      redis.hmset "param_val:#{preset.id}", "date_time", preset.date_time, "val_numeric", y, "parameter_id", params["parameter"].to_i, "subject_id", params["subject"].to_i, "formula_type", "по уставкам"
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
end