class WordsController < ApplicationController

  def show
    @word = Word.find_by_name params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @word.to_xml(:except => [:html, :id]) }
      format.json  { render :json => @word.to_json(:except => :html) }
    end
  end

end
