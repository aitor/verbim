require 'progress_bar'

module SupportFunctions
  FILE_NAME = "data/spanish-lemario-20101017.txt"
  URL = "http://buscon.rae.es/draeI/SrvltGUIBusUsual?TIPO_BUS=3&LEMA="

  def self.scrap!
    lines = File.readlines(FILE_NAME)
    bar = ProgressBar.new(lines.size)

    lines.each do |line|
      w = line.strip
      begin
        Drae::API.new.define(w)
        error = Error.find_by_word(w)
        error.destroy if error
      rescue Exception=>e
        error = Error.find_by_word(w)
        if error
          error.message = (e.message + "\n" + e.backtrace.join("\n"))
          error.save
        else
          Error.create(:word => w, :message => (e.message + "\n" + e.backtrace.join("\n")))
        end
      end
      bar.increment!
    end
  end
end