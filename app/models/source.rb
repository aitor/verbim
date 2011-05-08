class Source
  include MongoMapper::Document

  key :kind, String
  key :word, String

  belongs_to :etymology

end
