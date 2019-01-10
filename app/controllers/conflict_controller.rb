class ConflictController < ApplicationController

  include AjaxHelper 

  def index
    set_picture
    next_picture
    @count = 0
    session[:voting_id] = Array.new
  end

  def elo
    begin
      winer = Picture.find(params[:win])
      loser = Picture.find(params[:lose])
      win = Elo::Player.new(rating: winer.rating, k_factor: 12)
      lose = Elo::Player.new(rating: loser.rating, k_factor: 12)

      session[:voting_id].push(winer.id)

      win.wins_from(lose)
      lose.loses_from(win)

      winer.rating = win.rating
      loser.rating = lose.rating
      winer.win += 1
      loser.lose += 1
      winer.save
      loser.save

      @picture1 = Picture.find params[:next1]
      @picture2 = Picture.find params[:next2]

      while @picture1.picture_present == false || @picture2.picture_present == false
        set_picture
      end
    rescue
      set_picture
    end
    next_picture

    @count = params[:count].to_i + 1
    if @count >= 10
      respond_to do |format|
        format.js { render ajax_redirect_to(conflict_result_path) }
      end
    end
  end

  def result
    @pictures = Picture.where(id: session[:voting_id]).order(['field(id, ?)', session[:voting_id].reverse])
  end
  
  def img_blank
    begin
      picture = Picture.find(params[:picture_id])
      picture.picture_present = false
      picture.save
    rescue

    end

    redirect_back(fallback_location: root_path)
  end

  private
    def set_picture
      Picture.find( Picture.where(picture_present: true).pluck(:id).sample )
      @picture1 = Picture.find( Picture.pluck(:id).sample )
      begin
        @picture2 = Picture.find( Picture.where(picture_present: true).pluck(:id).sample )
      end while @picture1.id == @picture2.id
    end

    def next_picture
      @next1 = Picture.find( Picture.where(picture_present: true).pluck(:id).sample )
      begin
        @next2 = Picture.find( Picture.where(picture_present: true).pluck(:id).sample )
      end while @next1.id == @next2.id
    end
end
