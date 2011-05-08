require 'pp'

desc "rae non-for-profit toy"
task :raediator => :environment do

  @dictionary = Drae::API.new
  pp @dictionary.define(ENV['word'] || 'chacal')
  
end

