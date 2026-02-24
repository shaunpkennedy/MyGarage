class SessionsController < ApplicationController
  def new
    redirect_to vehicles_path if logged_in?
  end

  def create
    user = User.authenticate(params[:username], params[:password])

    if user
      session[:user_id] = user.id
      flash[:notice] = "Welcome back, #{user.username}!"
      redirect_to vehicles_path
    else
      flash.now[:alert] = 'Invalid username or password.'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    @current_user = nil
    flash[:notice] = 'You have been logged out.'
    redirect_to login_path
  end
end
