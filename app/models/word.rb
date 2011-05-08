class Word
  include MongoMapper::Document

  key :name,  String
  key :html,  String # original scrapped file
  
  many :lemas
  
end
