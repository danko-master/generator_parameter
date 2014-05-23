class ParamVal < ActiveRecord::Base
  
  def self.search(parameter_id, subject_id, date_start, date_end)
    records = ParamVal.where(parameter_id: parameter_id).where(subject_id: subject_id)
    records = records.where("date_time >= ?", date_start) if date_start
    records = records.where("date_time <= ?", date_end) if date_end
    records
  end
end