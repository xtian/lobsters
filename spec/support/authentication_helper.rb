# frozen_string_literal: true

module AuthenticationHelper
  def stub_login_as(user)
    user.update_column(:session_token, 'asdf')

    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ApplicationController).to receive(:session).and_return(u: 'asdf')
    # rubocop:enable RSpec/AnyInstance
  end
end
