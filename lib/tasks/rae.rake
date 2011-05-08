require 'pp'
require 'support_functions'

namespace :verbim do
  desc "rae non-for-profit toy"
  task :raediator => :environment do

    @dictionary = Drae::API.new
    pp @dictionary.create_word(ENV['word'] || 'chacal')

  end

  desc "scrapper"
  task :scrapper => :environment do
    SupportFunctions.scrap!
  end
end
