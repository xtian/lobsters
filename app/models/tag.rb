# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings, dependent: :delete_all
  has_many :stories, through: :taggings
  has_many :tag_filters, dependent: :destroy
  has_many :filtering_users,
           class_name: 'User',
           through: :tag_filters,
           source: :user,
           dependent: :delete_all

  after_save :log_modifications

  attr_accessor :edit_user_id, :stories_count
  attr_writer :filtered_count

  validates :tag, length: { maximum: 25 }, presence: true, uniqueness: true
  validates :description, length: { maximum: 100 }
  validates :hotness_mod, inclusion: { in: -10..10 }

  scope :active, -> { where(inactive: false) }

  def to_param
    tag
  end

  def self.all_with_filtered_counts_for(user)
    counts = TagFilter.group(:tag_id).count

    Tag.active.order(:tag).select { |t| t.valid_for?(user) }.map do |t|
      t.filtered_count = counts[t.id].to_i
      t
    end
  end

  def self.all_with_story_counts_for(user)
    counts = Tagging.group(:tag_id).count

    Tag.active.order(:tag).select { |t| t.valid_for?(user) }.map do |t|
      t.stories_count = counts[t.id].to_i
      t
    end
  end

  def css_class
    "tag tag_#{tag}" + (is_media? ? ' tag_is_media' : '')
  end

  def valid_for?(user)
    if privileged?
      user&.is_moderator?
    else
      true
    end
  end

  def filtered_count
    @_filtered_count ||= TagFilter.where(tag_id: id).count
  end

  def log_modifications
    Moderation.create do |m|
      m.action = if new_record?
                   'Created new tag ' + changes.map { |f, c| "with #{f} '#{c[1]}'" }.join(', ')
                 else
                   "Updating tag #{tag}, " + saved_changes
                     .map { |f, c| "changed #{f} from '#{c[0]}' to '#{c[1]}'" }
                     .join(', ')
                 end
      m.moderator_user_id = edit_user_id
      m.tag_id = id
    end
  end
end
