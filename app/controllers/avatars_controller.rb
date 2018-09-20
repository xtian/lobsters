# frozen_string_literal: true

class AvatarsController < ApplicationController
  before_action :require_logged_in_user, only: [:expire]

  ALLOWED_SIZES = [16, 32, 100, 200].freeze

  CACHE_DIR = "#{Rails.root}/public/avatars/"

  def expire
    expired = 0

    files = Dir.entries(CACHE_DIR).select do |f|
      f.match(/\A#{@user.username}-(\d+)\.png\z/)
    end

    files.each do |f|
      Rails.logger.debug "Expiring #{f}"
      File.unlink("#{CACHE_DIR}/#{f}")
      expired += 1
    rescue StandardError => e
      Rails.logger.error "Failed expiring #{f}: #{e}"
    end

    flash[:success] = "Your avatar cache has been purged of #{'file'.pluralize(expired)}"
    redirect_to '/settings'
  end

  def show
    username, size = params[:username_size].to_s.scan(/\A(.+)-(\d+)\z/).first
    size = size.to_i

    raise ActionController::RoutingError, 'invalid size' unless ALLOWED_SIZES.include?(size)

    unless username.match?(User::VALID_USERNAME)
      raise ActionController::RoutingError, 'invalid user name'
    end

    u = User.where(username: username).first!

    unless (av = u.fetched_avatar(size))
      raise ActionController::RoutingError, 'failed fetching avatar'
    end

    Dir.mkdir(CACHE_DIR) unless Dir.exist?(CACHE_DIR)

    File.open("#{CACHE_DIR}/.#{u.username}-#{size}.png", 'wb+') do |f|
      f.write av
    end

    File.rename("#{CACHE_DIR}/.#{u.username}-#{size}.png", "#{CACHE_DIR}/#{u.username}-#{size}.png")

    response.headers['Expires'] = 1.hour.from_now.httpdate
    send_data av, type: 'image/png', disposition: 'inline'
  end
end
