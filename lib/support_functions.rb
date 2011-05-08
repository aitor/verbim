require 'progress_bar'

module SupportFunctions
  FILE_NAME = "data/spanish-lemario-20101017.txt"

  def self.scrap!(force=false)
    
    lines = File.readlines(FILE_NAME)
    bar = ProgressBar.new(lines.size)
    
    last_word_indexed = Word.sort(:name).last
    lines.each do |line|
      puts ("Processing #{line}")
      w = line.strip
      begin
        Drae::API.new.define(w)
      rescue Exception=>e
        error(e.message + "\n" + e.backtrace.join("\n"))
      end
      bar.increment!
    end
    
  end
  def self.error(msg)
    log(msg, "ERROR")
  end
  def self.log(msg, type="DEBUG")
    Log.create(:type => type, :message => msg)
  end
end