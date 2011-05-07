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
      params = { 'TIPO_BUS' => 3, 'LEMA' => word}
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
      container = (doc/:div)
      { :id        => (container/:a).attribute("name").value.to_i,
        :word      => container.search(".eLema").first.text,
        :etymology => process_etymology(container),
        :meanings  => process_raw_meanings((container/:p)[3, :end]) }

    end

    def process_etymology(container)
      anchor = container.search(".eEtimo a").first

      if !anchor.nil?
        [ anchor.attribute("title").text,
          container.search(".eEtimo i").text]*" "
      else
        " "
      end
    end

    def process_raw_meanings(raw_meanings)
      raw_meanings.collect do |p|
        { :order   => p.search(".eOrdenAcepLema").text.lstrip.rstrip[0,1].to_i,
          :abbr    => p.search(".eAbrv")[1].text.lstrip.rstrip,
          :meaning => p.search(".eAcep").text.lstrip.rstrip }
      end
    end
  end
end