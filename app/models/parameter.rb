class Parameter < ActiveRecord::Base
  belongs_to :uom
  
  # Периодичность
  def self.periodicity
    [ 
      ["Ежегодно", "365"],
      ["Ежемесячно", "30"],
      ["Еженедельно", "7"],
      ["Ежедневно", "1"]
    ]
  end
end
