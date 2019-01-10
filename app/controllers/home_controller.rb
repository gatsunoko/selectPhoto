class HomeController < ApplicationController
  def index
    @pictures = Picture.all.order(rating: :desc).offset(0).limit(10)
  end
end
