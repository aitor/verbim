class Source
  include MongoMapper::Document

  key :lang, String
  key :word, String

  belongs_to :etymology

end
