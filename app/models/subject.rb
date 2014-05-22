class Subject < ActiveRecord::Base
  has_many :subject_kladr
  has_many :kladr, through: :subject_kladr
end