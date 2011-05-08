require 'pp'
require 'support_functions'

desc "rae non-for-profit toy"
task :raediator => :environment do

  @dictionary = Drae::API.new
  pp @dictionary.define(ENV['word'] || 'chacal')
  
end

desc "scrapper"
task :scrapper => :environment do
  SupportFunctions.scrap!
end
