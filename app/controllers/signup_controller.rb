# frozen_string_literal: true

class SignupController < ApplicationController
  before_action :require_logged_in_user, :only => :invite
  before_action :check_for_read_only_mode

  def index
    if @user
      flash[:error] = 'You are already signed up.'
      return redirect_to '/'
    end
    if Rails.application.open_signups?
      redirect_to action: :invited, invitation_code: 'open' and return
    end
    @title = 'Signup'
  end

  def invite
    @title = 'Pass Along an Invitation'
  end

  def invited
    if @user
      flash[:error] = 'You are already signed up.'
      return redirect_to '/'
    end

    if !Rails.application.open_signups?
      if !(@invitation = Invitation.unused.where(:code => params[:invitation_code].to_s).first)
        flash[:error] = 'Invalid or expired invitation'
        return redirect_to '/signup'
      end
    end

    @title = 'Signup'

    @new_user = User.new

    @new_user.email = @invitation.email unless Rails.application.open_signups?

    render :action => 'invited'
  end

  def signup
    if !Rails.application.open_signups?
      if !(@invitation = Invitation.unused.where(:code => params[:invitation_code].to_s).first)
        flash[:error] = 'Invalid or expired invitation.'
        return redirect_to '/signup'
      end
    end

    @title = 'Signup'

    @new_user = User.new(user_params)

    @new_user.invited_by_user_id = @invitation.user_id unless Rails.application.open_signups?

    if @new_user.save
      @invitation&.update(used_at: Time.current, new_user: @new_user)
      session[:u] = @new_user.session_token
      flash[:success] = "Welcome to #{Rails.application.name}, " \
                        "#{@new_user.username}!"

      return redirect_to '/signup/invite'
    else
      render :action => 'invited'
    end
  end

private

  def user_params
    params.require(:user).permit(
      :username, :email, :password, :password_confirmation, :about
    )
  end
end
