class Complex
  include MongoMapper::Document

  key :figure,  String

  belongs_to :lema
  many :meanings, :as => :meaningful
  
end