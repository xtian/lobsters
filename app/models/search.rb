# frozen_string_literal: true

class Search
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::AttributeMethods
  extend ActiveModel::Naming

  attr_accessor :q, :order
  attr_accessor :results, :page, :total_results, :per_page
  attr_writer :what

  validates :q, length: { minimum: 2 }

  def initialize
    @q = ''
    @what = 'stories'
    @order = 'relevance'

    @page = 1
    @per_page = 20

    @results = []
    @total_results = -1
  end

  def max_matches
    100
  end

  def persisted?
    false
  end

  def to_url_params
    %i[q what order].map { |p| "#{p}=#{CGI.escape(public_send(p).to_s)}" }.join('&amp;')
  end

  def page_count
    total = total_results.to_i

    total = max_matches if total == -1 || total > max_matches

    ((total - 1) / per_page.to_i) + 1
  end

  def what
    case @what
    when 'comments'
      'comments'
    else
      'stories'
    end
  end

  def with_tags(base, tag_scopes)
    base
      .joins({ taggings: :tag }, :user)
      .where(tags: { tag: tag_scopes })
      .having('COUNT(stories.id) = ?', tag_scopes.length)
  end

  def with_stories_in_domain(base, domain)
    reg = Regexp.new("//([^/]*\.)?#{domain}/")
    quoted = ActiveRecord::Base.connection.quote_string(reg.source)

    base.where("stories.url ~* '#{quoted}'")
  rescue RegexpError
    base
  end

  def with_stories_matching_tags(base, tag_scopes)
    story_ids_matching_tags = with_tags(
      Story.unmerged.where(is_expired: false), tag_scopes
    ).group('stories.id').select(:id).map(&:id)

    base.where(story_id: story_ids_matching_tags)
  end

  def search_for_user!(user)
    self.results = []
    self.total_results = 0

    # extract domain query since it must be done separately
    domain = nil
    tag_scopes = []
    words = q.to_s.split(' ').reject do |w|
      if (m = w.match(/^domain:(.+)$/))
        domain = m[1]
      elsif (m = w.match(/^tag:(.+)$/))
        tag_scopes << m[1]
      end
    end.join(' ')

    base = nil

    case what
    when 'stories'
      base = Story.unmerged.where(is_expired: false)
      base = with_stories_in_domain(base, domain) if domain.present?

      self.results = if words.present?
                       base = base.search(words)

                       if tag_scopes.present?
                         base = with_tags(base, tag_scopes)
                         base.group("stories.id, #{PgSearch::Configuration.alias('stories')}.rank")
                       else
                         base.includes({ taggings: :tag }, :user)
                       end

                     elsif tag_scopes.present?
                       base = with_tags(base, tag_scopes)
                       base.group('stories.id')
                     else
                       base.includes({ taggings: :tag }, :user)
                     end

      case order
      when 'relevance'
        if words.present?
          results
        else
          results.reorder!('stories.created_at DESC')
        end
      when 'newest'
        results.reorder!('stories.created_at DESC')
      when 'points'
        results.reorder!("#{Story.score_sql} DESC")
      end

    when 'comments'
      base = Comment.active
      base = with_stories_in_domain(base.joins(:story), domain) if domain.present?
      base = with_stories_matching_tags(base, tag_scopes) if tag_scopes.present?

      if words.present?
        base = base.search_by_comment(words)
          .group("comments.id, #{PgSearch::Configuration.alias('comments')}.rank")
      end

      self.results = base.includes(:user, :story)

      case order
      when 'relevance'
        results
      when 'newest'
        results.reorder!('created_at DESC')
      when 'points'
        results.reorder!("#{Comment.score_sql} DESC")
      end
    end

    self.total_results = results.length

    self.page = page_count if page > page_count
    self.page = 1 if page < 1

    self.results = results
      .limit(per_page)
      .offset((page - 1) * per_page)

    # if a user is logged in, fetch their votes for what's on the page
    if user
      case what
      when 'stories'
        votes = Vote.story_votes_by_user_for_story_ids_hash(user.id, results.map(&:id))

        results.each do |r|
          r.vote = votes[r.id] if votes[r.id]
        end

      when 'comments'
        votes = Vote.comment_votes_by_user_for_comment_ids_hash(user.id, results.map(&:id))

        results.each do |r|
          r.current_vote = votes[r.id] if votes[r.id]
        end
      end
    end
  rescue ActiveRecord::StatementInvalid
    # this is most likely bad boolean chars
    self.results = []
    self.total_results = -1
  end
end
