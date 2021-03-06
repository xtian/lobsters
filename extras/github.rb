# frozen_string_literal: true

# rubocop:disable Naming/VariableName, Style/ClassVars

class Github
  cattr_accessor :CLIENT_ID, :CLIENT_SECRET

  # these need to be overridden in config/initializers/production.rb
  @@CLIENT_ID = nil
  @@CLIENT_SECRET = nil

  def self.enabled?
    self.CLIENT_ID.present?
  end

  def self.oauth_consumer
    OAuth::Consumer.new(self.CLIENT_ID, self.CLIENT_SECRET, site: 'https://api.github.com')
  end

  def self.token_and_user_from_code(code)
    s = Sponge.new
    res = s.fetch(
      'https://github.com/login/oauth/access_token',
      :post,
      client_id: self.CLIENT_ID,
      client_secret: self.CLIENT_SECRET,
      code: code
    )
    ps = CGI.parse(res)
    tok = ps['access_token'].first

    if tok.present?
      res = s.fetch("https://api.github.com/user?access_token=#{tok}")
      js = JSON.parse(res)
      return [tok, js['login']] if js && js['login'].present?
    end

    [nil, nil]
  end

  def self.oauth_auth_url(state)
    "https://github.com/login/oauth/authorize?client_id=#{self.CLIENT_ID}&" \
      "state=#{state}"
  end
end
# rubocop:enable Naming/VariableName, Style/ClassVars
