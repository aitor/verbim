class Etymology
  include MongoMapper::Document

  key :original,  String

  belongs_to :lema
  many :sources
  
end