class Kladr < ActiveRecord::Base
  self.table_name = "kladr"
  has_many :subject_kladr
  has_many :subject, through: :subject_kladr
end