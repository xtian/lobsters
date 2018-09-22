# frozen_string_literal: true

pwd = SecureRandom.base58

User.create(
  username: 'inactive-user',
  email: 'inactive-user@example.com',
  password: pwd,
  password_confirmation: pwd
)

User.create(
  username: 'test',
  email: 'test@example.com',
  password: 'test',
  password_confirmation: 'test',
  is_admin: true,
  is_moderator: true
)

Tag.create(tag: 'test')

# rubocop:disable Rails/Output
puts '
created:
  * an admin with username/password of test/test
  * inactive-user for disowned comments by deleted users
  * a test tag
If this is a dev environment, you probably want to run `rails fake_data`
If this is production, you want to run `rails console` to rename your admin and tag
'
# rubocop:enable Rails/Output
