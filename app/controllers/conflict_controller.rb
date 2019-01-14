class ConflictController < ApplicationController

  include AjaxHelper 

  def index
    set_picture
    if @conflict.blank?
      @conflict = Conflict.create(picture_1: @picture1.id, picture_2: @picture2.id, count: 0)
    end
    @conflict_id = @conflict.id

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

      @conflict = Conflict.find params[:conflict_id]

      #CSRFで表示されていない画像のIDを送ってきたらエラーを起こす
      if (@conflict.picture_1.to_i != params[:win].to_i && @conflict.picture_2.to_i != params[:win].to_i) &&
      (@conflict.picture_1.to_i  != params[:lose].to_i  || @conflict.picture_2.to_i  != params[:lose].to_i )
        raise
      end

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

      @conflict.update(picture_1: @picture1.id, picture_2: @picture2.id, count: @conflict.count + 1)

      while @picture1.picture_present == false || @picture2.picture_present == false
        set_picture
      end
    rescue
      set_picture
    end
    next_picture

    @count = params[:count].to_i + 1
    if @count >= 10 || @conflict.count >= 10
      @conflict.destroy
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

      if params[:conflict_id].present?
        @conflict = Conflict.find params[:conflict_id]
        @conflict_id = @conflict.id
        @conflict.update(picture_1: @picture1.id, picture_2: @picture2.id)
      end
    end

    def next_picture
      @next1 = Picture.find( Picture.where(picture_present: true).pluck(:id).sample )
      begin
        @next2 = Picture.find( Picture.where(picture_present: true).pluck(:id).sample )
      end while @next1.id == @next2.id

      if params[:conflict_id].present?
        @conflict = Conflict.find params[:conflict_id]
        @conflict_id = @conflict.id
      end
    end
end
