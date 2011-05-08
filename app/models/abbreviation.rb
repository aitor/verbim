class Abbreviation
  include MongoMapper::Document

  key :extended,  String
  key :abbr,      String
  
  belongs_to :meaning
    
end