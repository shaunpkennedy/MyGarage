class HomeController < ApplicationController
  def index
    redirect_to vehicles_path if logged_in?
  end
end
