#################################################################################################
#################################################################################################
#################################################################################################
###########                                                                      ################
###########                                                                      ################
###########     Original work of Vicente Reig Rincón de Arellano (author)        ################
###########            on a public fork of my project drae                       ################
###########                                                                      ################
###########     https://github.com/vicentereig/drae/blob/master/lib/drae.rb      ################
###########                                                                      ################
###########             Thank you mate, I owe you a beer.                        ################
###########                                         -AGR                         ################
###########                                                                      ################
#################################################################################################
#################################################################################################
#################################################################################################
#################################################################################################

require 'rubygems'
require 'httparty'
require 'nokogiri'
require 'digest'

module Drae

  class API
    attr_accessor :response

    include HTTParty
    base_uri 'http://buscon.rae.es'
    format :html

    class << self
      def path
        "/draeI/SrvltGUIBusUsual"
      end
    end

    def define(word)
      @word = word
      params = { 'TIPO_BUS' => 3, 'LEMA' => @word}
      perform_request(params)
      parse_response(response)
    end

    private

    def perform_request(params)
      key = API.path + params.collect {|k,v| "#{k}=#{v}" }*"&"
      key = Digest::SHA256.hexdigest(key)
      if File.exists?("#{key}.html")
        @response = File.read("#{key}.html")
      else
        @response = self.class.get(API.path, :query => params)
        File.open("#{key}.html", "w") do |f|
          f << @response
        end
      end
      @response
    end

    def parse_response(response)
      doc = Nokogiri::HTML(response)
      
      returning [] do |lemas|
        (doc/:div).each do |lema| 
          lemas << parse_lema(lema)
        end
      end
    end
    
    def parse_lema(div)
      meanings  = div.xpath(".//span[@class='eOrdenAcepLema']").map{|span| span.parent}
      complex   = div.xpath(".//span[@class='eFCompleja']").map{|span| span.parent}

      etymology = div.xpath(".//span[@class='eEtimo']").first

      ety_info = if etymology
        {
          :original =>etymology.parent.text.strip.gsub(%r{</?[^>]+?>}, '')[1..-3], 
          :sources => process_etymology(etymology.parent)
        }
      else
        {}
      end
      
      { 
        :id        => (div/:a).attribute("name").value.to_i,
        :word      => div.search(".eLema").first.text,
        :etymology => ety_info,
        :meanings  => process_meanings(meanings),
        :complex   => process_complex(complex) 
      }
      
    end

    #<span class="eEtimo"> (<a>Del</a> <a title="francés o francesa">fr.</a> <i>chacal</i></span>
    #<span class="eEtimo">, <a>este del</a> <a>turco</a> <i>çakal</i></span>
    #<span class="eEtimo">, <a>este del</a> <a>persa</a> <i>šaḡal,</i></span>
    #<span class="eEtimo"> y este <a>del</a> <a title="sánscrito o sánscrita">sánscr.</a> <i>sṛgâlá</i>).</span>
    # pero tambien
    #<span class="eEtimo">(<a title="del participio de">Del part. de</a> <i>dar</i></span>
    def process_etymology(etymology)
      returning [] do |sources|
        etymology.search(".eEtimo").each do |etimo| 
          word = etimo.search("i").first && etimo.search("i").first.text
          lang = etimo.search("a").last
          lng = if lang
            lang['title'] ? lang['title'] : lang.text
          else
            nil
          end
          sources << {:lang => lng, :word => word}
        end
      end
    end

    #<a name="0_1"></a>
    #<span class="eOrdenAcepLema"><b> 1.     </b></span>
    #<span class="eAbrv"> <span class="eAbrv" title="nombre masculino">m.</span></span>
    #<span class="eAcep"> Mamífero carnívoro de la familia de los Cánidos, de un [...] </span>
    #
    # check this... OH MY FUCKING GOD:
    # <span class="eAbrvNoEdit"><span class="eAbrvNoEdit" title="nombre femenino">f.</span></span>
    def process_meanings(meanings)
      meanings.collect do |meaning|
        abbr = meaning.search(".eAbrv .eAbrv").first || meaning.search(".eAbrvNoEdit .eAbrvNoEdit").first
        { 
          :order   => meaning.search(".eOrdenAcepLema").text.strip[0..-2].to_i, 
          :abbr    => {
                        :abbr => abbr.text,
                        :extended => abbr['title']
                      },
          :meaning => meaning.search(".eAcep").text.strip 
        }
      end
    end
    
    #<p style="margin-left:0em; margin-bottom:-0.5em">
    #  <a name="estar_algo_como_un_dado." id="estar_algo_como_un_dado."></a> <span class="eFCompleja"><b>estar</b> algo <b>como un</b> <b>~</b><b>.</b></span>
    #</p>
    def process_complex(complex)
      complex.collect do |c|
        {
          :figure => c.search(".eFCompleja").text,
          :meanings => process_complex_meanings(c)
        }
      end
    end
    
    #<p style="margin-left:2em; margin-bottom:-0.5em">
    #  <a name="estar_algo_como_un_dado.1" id="estar_algo_como_un_dado.1"></a> <span class="eOrdenAcepFC"><b>1.</b></span> <span class="eAbrv"><span class="eAbrv" title="locución verbal">loc. verb.</span></span> <span class="eAcep">Estar bien ajustado y arreglado.</span>
    #</p>
    def process_complex_meanings(c)
      name_attr = c.search("a").first['name']
      meanings = c.parent.xpath(".//a[starts-with(@name, '#{name_attr}')]").map{|span| span.parent}
      returning [] do |m|
        meanings.each do |mean| 
          unless mean == c
            abbr = mean.search(".eAbrv .eAbrv").first || mean.search(".eAbrvNoEdit .eAbrvNoEdit").first
            m <<  {
                    :order   => mean.search(".eOrdenAcepFC").text.strip[0..-2].to_i,
                    :abbr    => {
                                  :abbr => abbr.text,
                                  :extended => abbr['title']
                                },
                    :meaning => mean.search(".eAcep").text.strip 
                  }
          end
        end
      end
    end
    
  end
end