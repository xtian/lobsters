# frozen_string_literal: true

class Invitation < ApplicationRecord
  belongs_to :user
  belongs_to :new_user, class_name: 'User', inverse_of: nil, required: false

  scope :used, -> { where.not(:used_at => nil) }
  scope :unused, -> { where(:used_at => nil) }

  validates :user, presence: true
  validate do
    errors.add(:email, 'is not valid') unless email.to_s.match?(/\A[^@ ]+@[^ @]+\.[^ @]+\z/)
  end

  before_validation :create_code, :on => :create

  def create_code
    (1...10).each do |tries|
      raise 'too many hash collisions' if tries == 10

      self.code = Utils.random_str(15)
      break unless Invitation.exists?(:code => code)
    end
  end

  def send_email
    InvitationMailer.invitation(self).deliver_now
  end
end
