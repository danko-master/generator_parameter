class SubjectKladr < ActiveRecord::Base
  self.table_name = "subject_kladr"
  belongs_to :subject
  belongs_to :kladr
end