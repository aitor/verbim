class Log
  include MongoMapper::Document

  key :type,    String
  key :message, String
end