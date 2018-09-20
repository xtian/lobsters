# frozen_string_literal: true

class Pushover
  # these need to be overridden in config/initializers/production.rb
  cattr_accessor :API_TOKEN
  cattr_accessor :SUBSCRIPTION_CODE

  def self.enabled?
    self.API_TOKEN.present?
  end

  def self.push(user, params)
    return unless enabled?

    begin
      params[:message] = '(No message)' if params[:message].to_s == ''

      s = Sponge.new
      s.fetch('https://api.pushover.net/1/messages.json', :post, {
        token: self.API_TOKEN,
        user: user
      }.merge(params))
    rescue StandardError => e
      Rails.logger.error "error sending to pushover: #{e.inspect}"
    end
  end

  def self.subscription_url(params)
    u = "https://pushover.net/subscribe/#{self.SUBSCRIPTION_CODE}"
    u += "?success=#{CGI.escape(params[:success])}"
    u += "&failure=#{CGI.escape(params[:failure])}"
    u
  end
end
