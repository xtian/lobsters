# frozen_string_literal: true

class InvitationsController < ApplicationController
  before_action :require_logged_in_user, except: %i[build create_by_request confirm_email]

  def build
    if Rails.application.allow_invitation_requests?
      @invitation_request = InvitationRequest.new
    else
      flash[:error] = 'Public invitation requests are not allowed.'
      redirect_to '/login'
    end
  end

  def index
    unless @user.can_see_invitation_requests?
      flash[:error] = 'Your account is not permitted to view invitation requests.'
      return redirect_to '/'
    end

    @invitation_requests = InvitationRequest.where(is_verified: true)
  end

  def confirm_email
    unless (ir = InvitationRequest.where(code: params[:code].to_s).first)
      flash[:error] = 'Invalid or expired invitation request'
      return redirect_to '/invitations/request'
    end

    ir.is_verified = true
    ir.save!

    flash[:success] = 'Your invitation request has been validated and ' \
                      'will now be shown to other logged-in users.'
    redirect_to '/invitations/request'
  end

  def create
    unless @user.can_invite?
      flash[:error] = 'Your account cannot send invitations'
      redirect_to '/settings'
      return
    end

    i = Invitation.new
    i.user_id = @user.id
    i.email = params[:email]
    i.memo = params[:memo]

    i.save!
    i.send_email
    flash[:success] = "Successfully e-mailed invitation to #{params[:email]}."

    if params[:return_home]
      return redirect_to '/'
    else
      return redirect_to '/settings'
    end
  end

  def create_by_request
    if Rails.application.allow_invitation_requests?
      @invitation_request = InvitationRequest.new(
        params.require(:invitation_request).permit(:name, :email, :memo)
      )

      @invitation_request.ip_address = request.remote_ip

      if @invitation_request.save
        flash[:success] = 'You have been e-mailed a confirmation to ' \
                          "#{params[:invitation_request][:email]}."
        return redirect_to '/invitations/request'
      else
        render action: :build
      end
    else
      redirect_to '/login'
    end
  end

  def send_for_request
    unless @user.can_see_invitation_requests?
      flash[:error] = 'Your account is not permitted to view invitation ' \
                      'requests.'
      return redirect_to '/'
    end

    unless (ir = InvitationRequest.where(code: params[:code].to_s).first)
      flash[:error] = 'Invalid or expired invitation request'
      return redirect_to '/invitations'
    end

    i = Invitation.new
    i.user_id = @user.id
    i.email = ir.email
    i.save!
    i.send_email
    ir.destroy!
    flash[:success] = "Successfully e-mailed invitation to #{ir.name}."

    Rails.logger.info "[u#{@user.id}] sent invitiation for request " +
                      ir.inspect

    redirect_to '/invitations'
  end

  def delete_request
    return redirect_to '/invitations' unless @user.can_see_invitation_requests?

    unless (ir = InvitationRequest.where(code: params[:code].to_s).first)
      flash[:error] = 'Invalid or expired invitation request'
      return redirect_to '/invitations'
    end

    ir.destroy!
    flash[:success] = "Successfully deleted invitation request from #{ir.name}."

    Rails.logger.info "[u#{@user.id}] deleted invitation request " \
                      "from #{ir.inspect}"

    redirect_to '/invitations'
  end
end
