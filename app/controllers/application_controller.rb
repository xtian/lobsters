# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :authenticate_user

  # match this in your nginx config for bypassing the file cache
  TAG_FILTER_COOKIE = :tag_filters

  # TODO: returning false until 1. nginx wants to serve cached files
  # 2. the "stay logged in" cookie is separated from rails session cookie
  # (lobster_trap) which is sent even to logged-out visitors
  CACHE_PAGE = proc { false && @user.blank? && cookies[TAG_FILTER_COOKIE].blank? }

  def authenticate_user
    # eagerly evaluate, in case this triggers an IpSpoofAttackError
    request.remote_ip

    return true if Rails.application.read_only?

    if session[:u] &&
       (user = User.find_by(session_token: session[:u].to_s)) &&
       user.is_active?
      @user = user
      Rails.logger.info "  Logged in as user #{@user.id} (#{@user.username})"
    end

    true
  end

  def check_for_read_only_mode
    if Rails.application.read_only?
      flash.now[:error] = 'Site is currently in read-only mode.'
      return redirect_to '/'
    end

    true
  end

  def require_logged_in_user
    if @user
      true
    else
      session[:redirect_to] = request.original_fullpath if request.get?

      redirect_to '/login'
    end
  end

  def require_logged_in_moderator
    require_logged_in_user

    if @user
      if @user.is_moderator?
        true
      else
        flash[:error] = 'You are not authorized to access that resource.'
        return redirect_to '/'
      end
    end
  end

  def require_logged_in_admin
    require_logged_in_user

    if @user
      if @user.is_admin?
        true
      else
        flash[:error] = 'You are not authorized to access that resource.'
        return redirect_to '/'
      end
    end
  end

  def require_logged_in_user_or_400
    if @user
      true
    else
      render plain: 'not logged in', status: :bad_request
      false
    end
  end

  def tags_filtered_by_cookie
    @_tags_filtered_by_cookie ||= Tag.where(
      tag: cookies[TAG_FILTER_COOKIE].to_s.split(',')
    )
  end

  def agent_is_spider?
    ua = request.env['HTTP_USER_AGENT'].to_s
    (ua == '' || ua.match?(/(Google|bing|Slack|Twitter)bot|Slurp|crawler|Feedly|FeedParser|RSS/))
  end

  def find_user_from_rss_token
    if !@user && request[:format] == 'rss' && params[:token].to_s.present?
      @user = User.where(rss_token: params[:token].to_s).first
    end
  end
end
