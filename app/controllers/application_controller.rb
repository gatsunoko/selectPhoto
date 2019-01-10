class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def is_admin
    unless current_user.admin
      redirect_to root_path and return
    end
  end
end
