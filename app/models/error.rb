class Error
  include MongoMapper::Document

  key :word, String
  key :message, String
end