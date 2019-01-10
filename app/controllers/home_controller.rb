class HomeController < ApplicationController
  def index
    @pictures = Picture.all.order(rating: :desc).page(params[:page]).per(10)
  end
end
