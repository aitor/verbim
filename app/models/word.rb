class Word
  include MongoMapper::Document

  key :name, String
  key :html, String
end