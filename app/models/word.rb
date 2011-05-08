class Word
  include MongoMapper::Document

  key :name,  String
  key :html,  String # original scrapped file
  
  many :lemas
  
  
  def self.create_from_definition(word)
    definition = Drae::API.new.create_word(word)

    w = Word.find_by_name(word)
    definition.each do |d|
      
      lema = Lema.new(:name => d[:word], :raeid =>d[:id] )
      d[:meanings].each do |m|
        meaning = Meaning.new(:definition => m[:meaning], 
                    :order      => m[:order],
                    :abbreviations => [Abbreviation.new(:extended => m[:abbr][:extended], :abbr =>m[:abbr][:abbr])])
        lema.meanings << meaning
      end
      
      d[:complex].each do |cx|
        complex = Complex.new(:figure => cx[:figure])
        cx[:meanings].each do |cxm|
          cxmeaning = Meaning.new(:definition => cxm[:meaning], 
                                  :order      => cxm[:order],
                                  :abbreviations => [Abbreviation.new(:extended => cxm[:abbr][:extended], :abbr =>cxm[:abbr][:abbr])])
          complex.meanings << cxmeaning
        end
        lema.complexes << complex
      end
      
      etymology = Etymology.new(:original => d[:etymology][:original])
      
      d[:etymology][:sources] && d[:etymology][:sources].each do |s|
        etymology.sources << Source.new(:lang => s[:lang], :word => s[:word])
      end
      lema.etymology = etymology
      
      w.lemas << lema
      
    end  
    w.save
  end
  
end

