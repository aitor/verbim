class Meaning
  include MongoMapper::Document

  key :definition,  String
  key :order,       Integer
  
  belongs_to :meaningful, :polymorphic => true
  many :abbreviations
    
end