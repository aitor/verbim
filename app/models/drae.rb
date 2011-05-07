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
      puts div.inner_html
      meanings  = div.xpath(".//span[@class='eOrdenAcepLema']").map{|span| span.parent}
      complex   = div.xpath(".//span[@class='eFCompleja']").map{|span| span.parent}
      etymology = div.xpath(".//span[@class='eEtimo']").first.parent

      #puts "meanings #{meanings.count}"
      #puts "meanings #{meanings.first.inner_html}"
      #puts "meanings #{meanings.last.inner_html}"
      #puts "complex #{complex.count}"
      #puts "complex #{complex.first.inner_html}"
      #puts "complex #{complex.last.inner_html}"
      orig = etymology.text.gsub(%r{</?[^>]+?>}, '')[2..-3]
      
      puts orig
      { 
        :id        => (div/:a).attribute("name").value.to_i,
        :word      => div.search(".eLema").first.text,
        :etymology => {
                        :original =>etymology.text.gsub(%r{</?[^>]+?>}, '')[2..-3], 
                        :sources => process_etymology(etymology)
                      },
        :meanings  => process_meanings(meanings),
        :complex   => process_complex_forms(complex_forms) 
      }
      
    end

    #<span class="eEtimo"> (<a>Del</a> <a title="francés o francesa">fr.</a> <i>chacal</i></span>
    #<span class="eEtimo">, <a>este del</a> <a>turco</a> <i>çakal</i></span>
    #<span class="eEtimo">, <a>este del</a> <a>persa</a> <i>šaḡal,</i></span>
    #<span class="eEtimo"> y este <a>del</a> <a title="sánscrito o sánscrita">sánscr.</a> <i>sṛgâlá</i>).</span>
    def process_etymology(etymology)
      returning [] do |sources|
        etymology.search(".eEtimo").each do |etimo| 
          lang = etimo.search("a")[1]
          sources << {:lang => lang['title'] ? lang['title'] : lang.text, :word => etimo.search("i").first.text}
        end
      end

      
      anchor = container.search(".eEtimo a").first
      unless anchor
        [ anchor.attribute("title").text,
          container.search(".eEtimo i").text]*" "
      else
        " "
      end
    end

    def process_meanings(meanings)
      meanings.collect do |p|
        { 
          :order   => p.search(".eOrdenAcepLema").text.strip[0..-2].to_i, 
          #:abbr    => abbr.text.strip[0..-2],
          :meaning => p.search(".eAcep").text.strip 
        }
      end
    end
    def process_complex(complex)
      
    end
  end
end