class UsersController < ApplicationController

  before_action :require_login, except: :create

  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create
    auth_hash = request.env["omniauth.auth"]

    user = User.find_by(uid: auth_hash[:uid], provider: auth_hash["provider"])
    if user
      flash[:status] = :success
      flash[:result_text] = "Logged in as returning user #{user.username}"
      session[:user_id] = user.id
      return redirect_to root_path
    else
      if auth_hash["provider"] == "github"
        user = User.build_from_github(auth_hash)
      elsif auth_hash["provider"] == "google_oauth2"
        user = User.build_from_google(auth_hash)
      end
      if user
        if user.save
          flash[:status] = :success
          flash[:result_text] = "Logged in as new user #{user.username}"
          session[:user_id] = user.id
          return redirect_to root_path
        else
          flash[:status] = :failure
          flash[:messages] = "Could not create new user account: #{user.errors.messages}"
          return redirect_to root_path
        end
      end

    end

    # if auth_hash["provider"] == "github"
    #   user = User.build_from_github(auth_hash)
    # elsif auth_hash["provider"] == "google_oauth2"
    #   user = User.build_from_google(auth_hash)
    # end
    #
    # if user.save
    #   flash[:status] = :success
    #   flash[:result_text] = "Logged in as new user #{user.username}"
    #   session[:user_id] = user.id
    #   return redirect_to root_path
    # else
    #   flash[:status] = :failure
    #   flash[:messages] = "Could not create new user account: #{user.errors.messages}"
    #   return redirect_to root_path
    # end
  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
