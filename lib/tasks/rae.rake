desc "rae non-for-profit toy"
task :raediator => :environment do

  @dictionary = Drae::API.new
  
  @definition = @dictionary.define("flequillo")
  puts @definition.inspect
  
end

