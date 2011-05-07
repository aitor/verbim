require 'pp'

desc "rae non-for-profit toy"
task :raediator => :environment do

  @dictionary = Drae::API.new
  
  @definition = @dictionary.define(ENV['word'] || 'chacal')
  pp @definition
  
end

