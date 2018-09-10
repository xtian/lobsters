# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :story,
             :inverse_of => :comments
  has_many :votes,
           :dependent => :delete_all
  belongs_to :parent_comment,
             :class_name => 'Comment',
             :inverse_of => false,
             :required => false
  has_one :moderation,
          :class_name => 'Moderation',
          :inverse_of => :comment,
          :dependent => :destroy
  belongs_to :hat,
             :required => false
  has_many :taggings, through: :story

  attr_accessor :current_vote, :previewing, :indent_level

  before_validation :on => :create do
    assign_short_id_and_upvote
    assign_initial_confidence
    assign_thread_id
  end
  after_create :record_initial_upvote, :mark_submitter, :deliver_reply_notifications,
               :deliver_mention_notifications, :log_hat_use
  after_destroy :unassign_votes

  scope :active, -> { where(:is_deleted => false, :is_moderated => false) }

  DOWNVOTABLE_DAYS = 7
  DELETEABLE_DAYS = DOWNVOTABLE_DAYS * 2

  # the lowest a score can go
  DOWNVOTABLE_MIN_SCORE = -10

  # the score at which a comment should be collapsed
  COLLAPSE_SCORE = -5

  # after this many minutes old, a comment cannot be edited
  MAX_EDIT_MINS = (60 * 6)

  SCORE_RANGE_TO_HIDE = (-2 .. 4)

  validate do
    comment.to_s.strip == '' &&
      errors.add(:comment, 'cannot be blank.')

    user_id.blank? &&
      errors.add(:user_id, 'cannot be blank.')

    story_id.blank? &&
      errors.add(:story_id, 'cannot be blank.')

    (m = comment.to_s.strip.match(/\A(t)his([\.!])?$\z/i)) &&
      errors.add(:base, (m[1] == 'T' ? 'N' : 'n') + 'ope' + m[2].to_s)

    comment.to_s.strip.match?(/\Atl;?dr.?$\z/i) &&
      errors.add(:base, 'Wow!  A blue car!')

    comment.to_s.strip.match?(/\Ame too.?\z/i) &&
      errors.add(:base, 'Please just upvote the parent post instead.')

    hat.present? && user.wearable_hats.exclude?(hat) &&
      errors.add(:hat, 'not wearable by user')
  end

  def self.arrange_for_user(user)
    parents = order(Arel.sql('(upvotes - downvotes) < 0 ASC, confidence DESC'))
      .group_by(&:parent_comment_id)

    # top-down list of comments, regardless of indent level
    ordered = []

    ancestors = [nil] # nil sentinel so indent_level starts at 1 without add op.
    subtree = parents[nil]

    while subtree
      if (node = subtree.shift)
        children = parents[node.id]

        # for deleted comments, if they have no children, they can be removed
        # from the tree.  otherwise they have to stay and a "[deleted]" stub
        # will be shown
        if node.is_gone? && # deleted or moderated
           children.blank? && # don't have child comments
           (!user || (!user.is_moderator? && node.user_id != user.id))
          # admins and authors should be able to see their deleted comments
          next
        end

        node.indent_level = ancestors.length
        ordered << node

        # no children to recurse
        next unless children

        # drill down a level
        ancestors << subtree
        subtree = children
      else
        # climb back out
        subtree = ancestors.pop
      end
    end

    ordered
  end

  def self.regenerate_markdown
    Comment.record_timestamps = false

    Comment.all.find_each do |c|
      c.markeddown_comment = c.generated_markeddown_comment
      c.save(:validate => false)
    end

    Comment.record_timestamps = true

    nil
  end

  def self.score_sql
    Arel.sql("(CAST(upvotes AS #{Story.votes_cast_type}) - " \
      "CAST(downvotes AS #{Story.votes_cast_type}))")
  end

  def as_json(_options = {})
    h = [
      :short_id,
      :short_id_url,
      :created_at,
      :updated_at,
      :is_deleted,
      :is_moderated,
      :score,
      :upvotes,
      :downvotes,
      { :comment => (is_gone? ? "<em>#{gone_text}</em>" : :markeddown_comment) },
      :url,
      :indent_level,
      { :commenting_user => :user },
    ]

    js = {}
    h.each do |k|
      if k.is_a?(Symbol)
        js[k] = send(k)
      elsif k.is_a?(Hash)
        if k.values.first.is_a?(Symbol)
          js[k.keys.first] = send(k.values.first)
        else
          js[k.keys.first] = k.values.first
        end
      end
    end

    js
  end

  def assign_initial_confidence
    self.confidence = calculated_confidence
  end

  def assign_short_id_and_upvote
    self.short_id = ShortId.new(self.class).generate
    self.upvotes = 1
  end

  def assign_thread_id
    if parent_comment_id.present?
      self.thread_id = parent_comment.thread_id
    else
      self.thread_id = Keystore.incremented_value_for('thread_id')
    end
  end

  # http://evanmiller.org/how-not-to-sort-by-average-rating.html
  # https://github.com/reddit/reddit/blob/master/r2/r2/lib/db/_sorts.pyx
  def calculated_confidence
    n = (upvotes + downvotes).to_f
    return 0 if n == 0.0

    z = 1.281551565545 # 80% confidence
    p = upvotes.to_f / n

    left = p + (1 / ((2.0 * n) * z * z))
    right = z * Math.sqrt((p * ((1.0 - p) / n)) + (z * (z / (4.0 * n * n))))
    under = 1.0 + ((1.0 / n) * z * z)

    (left - right) / under
  end

  def comment=(com)
    self[:comment] = com.to_s.rstrip
    self.markeddown_comment = generated_markeddown_comment
  end

  def delete_for_user(user, reason = nil)
    Comment.record_timestamps = false

    self.is_deleted = true

    if user.is_moderator? && user.id != user_id
      self.is_moderated = true

      m = Moderation.new
      m.comment_id = id
      m.moderator_user_id = user.id
      m.action = 'deleted comment'

      m.reason = reason if reason.present?

      m.save
    end

    save(:validate => false)
    Comment.record_timestamps = true

    story.update_comments_count!
    self.user.update_comments_posted_count!
  end

  def deliver_mention_notifications
    plaintext_comment.scan(/\B\@([\w\-]+)/).flatten.uniq.each do |mention|
      next unless (u = User.find_by(:username => mention))
      next if u.id == user.id

      if u.email_mentions?
        begin
          EmailReply.mention(self, u).deliver_now
        rescue => e
          Rails.logger.error "error e-mailing #{u.email}: #{e}"
        end
      end

      next unless u.pushover_mentions?
      u.pushover!(
        :title => "#{Rails.application.name} mention by " \
          "#{user.username} on #{story.title}",
        :message => plaintext_comment,
        :url => url,
        :url_title => "Reply to #{user.username}"
      )
    end
  end

  def deliver_reply_notifications
    if parent_comment_id &&
       (u = parent_comment.try(:user)) &&
       u.id != user.id
      if u.email_replies?
        begin
          EmailReply.reply(self, u).deliver_now
        rescue => e
          Rails.logger.error "error e-mailing #{u.email}: #{e}"
        end
      end

      if u.pushover_replies?
        u.pushover!(
          :title => "#{Rails.application.name} reply from " \
            "#{user.username} on #{story.title}",
          :message => plaintext_comment,
          :url => url,
          :url_title => "Reply to #{user.username}"
        )
      end
    end
  end

  def generated_markeddown_comment
    Markdowner.to_html(comment)
  end

  def give_upvote_or_downvote_and_recalculate_confidence!(upvote, downvote)
    self.upvotes += upvote.to_i
    self.downvotes += downvote.to_i

    Comment.connection.execute("UPDATE #{Comment.table_name} SET " \
      "upvotes = COALESCE(upvotes, 0) + #{upvote.to_i}, " \
      "downvotes = COALESCE(downvotes, 0) + #{downvote.to_i}, " \
      "confidence = '#{calculated_confidence}' WHERE id = #{id}")

    story.recalculate_hotness!
  end

  def gone_text
    if is_moderated?
      'Comment removed by moderator ' +
        moderation.try(:moderator).try(:username).to_s << ': ' +
        (moderation.try(:reason) || 'No reason given')
    elsif user.is_banned?
      'Comment from banned user removed'
    else
      'Comment removed by author'
    end
  end

  def has_been_edited?
    updated_at && (updated_at - created_at > 1.minute)
  end

  def html_class_for_user
    c = []
    if !user.is_active?
      c.push 'inactive_user'
    elsif user.is_new?
      c.push 'new_user'
    elsif story&.user_is_author? &&
          story.user_id == user_id
      c.push 'user_is_author'
    end

    c.join('')
  end

  def is_deletable_by_user?(user)
    if user&.is_moderator?
      true
    elsif user && user.id == user_id
      created_at >= DELETEABLE_DAYS.days.ago
    else
      false
    end
  end

  def is_disownable_by_user?(user)
    user && user.id == user_id && created_at && created_at < DELETEABLE_DAYS.days.ago
  end

  def is_downvotable?
    if created_at && score > DOWNVOTABLE_MIN_SCORE
      Time.current - created_at <= DOWNVOTABLE_DAYS.days
    else
      false
    end
  end

  def is_editable_by_user?(user)
    if user && user.id == user_id
      if is_moderated?
        false
      else
        (Time.current.to_i - (updated_at ? updated_at.to_i :
          created_at.to_i) < (60 * MAX_EDIT_MINS))
      end
    else
      false
    end
  end

  def is_gone?
    is_deleted? || is_moderated?
  end

  def is_undeletable_by_user?(user)
    if user&.is_moderator?
      true
    elsif user && user.id == user_id && !is_moderated?
      true
    else
      false
    end
  end

  def log_hat_use
    return unless hat&.modlog_use

    m = Moderation.new
    m.created_at = created_at
    m.comment_id = id
    m.moderator_user_id = user.id
    m.action = "used #{hat.hat} hat"
    m.save!
  end

  def mark_submitter
    Keystore.increment_value_for("user:#{user_id}:comments_posted")
  end

  def mailing_list_message_id
    [
      'comment',
      short_id,
      is_from_email ? 'email' : nil,
      created_at.to_i,
    ].reject(&:!).join('.') << '@' + Rails.application.domain
  end

  def path
    story.comments_path + "#c_#{short_id}"
  end

  def plaintext_comment
    # TODO: linkify then strip tags and convert entities back
    comment
  end

  def record_initial_upvote
    Vote.vote_thusly_on_story_or_comment_for_user_because(
      1, story_id, id, user_id, nil, false
    )

    story.update_comments_count!
  end

  def score
    self.upvotes - self.downvotes
  end

  def score_for_user(u)
    if showing_downvotes_for_user?(u)
      score
    elsif u&.can_downvote?(self)
      '~'
    else
      '&nbsp;'.html_safe
    end
  end

  def short_id_url
    Rails.application.root_url + "c/#{short_id}"
  end

  def showing_downvotes_for_user?(u)
    (u&.is_moderator?) ||
           (created_at && created_at < 36.hours.ago) ||
           !SCORE_RANGE_TO_HIDE.include?(score)
  end

  def to_param
    short_id
  end

  def unassign_votes
    story.update_comments_count!
  end

  def url
    story.comments_url + "#c_#{short_id}"
  end

  def vote_summary_for_user(u)
    r_counts = {}
    r_users = {}
    # don't includes(:user) here and assume the caller did this already
    votes.each do |v|
      r_counts[v.reason.to_s] ||= 0
      r_counts[v.reason.to_s] += v.vote

      r_users[v.reason.to_s] ||= []
      r_users[v.reason.to_s].push v.user.username
    end

    r_counts.keys.sort.map {|k|
      if k == ''
        "+#{r_counts[k]}"
      else
        o = "#{r_counts[k]} #{Vote::COMMENT_REASONS[k]}"
        o << " (#{r_users[k].join(', ')})" if u&.is_moderator? && user_id != u.id
        o
      end
    }.join(', ')
  end

  def undelete_for_user(user)
    Comment.record_timestamps = false

    self.is_deleted = false

    if user.is_moderator?
      self.is_moderated = false

      if user.id != user_id
        m = Moderation.new
        m.comment_id = id
        m.moderator_user_id = user.id
        m.action = 'undeleted comment'
        m.save
      end
    end

    save(:validate => false)
    Comment.record_timestamps = true

    story.update_comments_count!
    self.user.update_comments_posted_count!
  end
end
