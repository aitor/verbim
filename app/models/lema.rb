class Lema
  include MongoMapper::Document

  key :name,  String
  key :raeid, String
  
  belongs_to :word
  many :meanings, :as => :meaningful
  many :complexes
  one :etymology
  
end