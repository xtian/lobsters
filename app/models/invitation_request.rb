# frozen_string_literal: true

class InvitationRequest < ApplicationRecord
  validates :name, presence: true
  validates :email, format: { with: /\A[^@ ]+@[^@ ]+\.[^@ ]+\Z/ }, presence: true
  validates :memo, format: { with: %r{https?://} }

  before_validation :create_code
  after_create :send_email

  def self.verified_count
    InvitationRequest.where(is_verified: true).count
  end

  def create_code
    (1...10).each do |tries|
      raise 'too many hash collisions' if tries == 10

      self.code = Utils.random_str(15)
      break unless InvitationRequest.exists?(code: code)
    end
  end

  def markeddown_memo
    Markdowner.to_html(memo)
  end

  def send_email
    InvitationRequestMailer.invitation_request(self).deliver_later
  end
end
