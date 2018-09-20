# frozen_string_literal: true

class StoriesController < ApplicationController
  caches_page :show, if: CACHE_PAGE

  before_action :require_logged_in_user_or_400,
                only: %i[upvote downvote unvote hide unhide preview save unsave
                         check_url_dupe]
  before_action :require_logged_in_user,
                only: %i[destroy create edit fetch_url_attributes new suggest]
  before_action :verify_user_can_submit_stories, only: %i[new create]
  before_action :find_user_story, only: %i[destroy edit undelete update]
  before_action :find_story!, only: %i[suggest submit_suggestions]
  around_action :track_story_reads, only: [:show], if: -> { @user.present? }

  def create
    @title = 'Submit Story'
    @cur_url = '/stories/new'

    @story = Story.new(story_params)
    @story.user_id = @user.id

    if @story.valid? && !(@story.already_posted_story && !@story.seen_previous)
      if @story.save
        ReadRibbon.where(user: @user, story: @story).first_or_create
        return redirect_to @story.comments_path
      end
    end

    render action: 'new'
  end

  def destroy
    unless @story.is_editable_by_user?(@user)
      flash[:error] = 'You cannot edit that story.'
      return redirect_to '/'
    end

    @story.is_expired = true
    @story.editor = @user

    if params[:reason].present? && @story.user_id != @user.id
      @story.moderation_reason = params[:reason]
    end

    @story.save(validate: false)

    redirect_to @story.comments_path
  end

  def edit
    unless @story.is_editable_by_user?(@user)
      flash[:error] = 'You cannot edit that story.'
      return redirect_to '/'
    end

    @title = 'Edit Story'

    @story.merge_story_short_id = @story.merged_into_story.short_id if @story.merged_into_story
  end

  def fetch_url_attributes
    s = Story.new
    s.fetching_ip = request.remote_ip
    s.url = params[:fetch_url]

    render json: s.fetched_attributes
  end

  def new
    @title = 'Submit Story'
    @cur_url = '/stories/new'

    @story = Story.new
    @story.fetching_ip = request.remote_ip

    if params[:url].present?
      @story.url = params[:url]

      sattrs = @story.fetched_attributes

      if sattrs[:url].present? && @story.url != sattrs[:url]
        flash.now[:notice] = 'Note: URL has been changed to fetched ' \
                             'canonicalized version'
        @story.url = sattrs[:url]
      end

      if (s = Story.find_similar_by_url(@story.url))
        if s.is_recent?
          # user won't be able to submit this story as new, so just redirect
          # them to the previous story
          flash[:success] = 'This URL has already been submitted recently.'
          return redirect_to s.comments_path
        else
          # user will see a warning like with preview screen
          @story.already_posted_story = s
        end
      end

      # ignore what the user brought unless we need it as a fallback
      @story.title = sattrs[:title]
      @story.title = params[:title] if @story.title.blank? && params[:title].present?
    end
  end

  def preview
    @story = Story.new(story_params)
    @story.user_id = @user.id
    @story.previewing = true

    @story.vote = Vote.new(vote: 1)
    @story.upvotes = 1

    @story.valid?

    @story.seen_previous = true

    render action: 'new', layout: false
  end

  def show
    # @story was already loaded by track_story_reads for logged-in users
    @story ||= Story.where(short_id: params[:id]).first!
    if @story.merged_into_story
      flash[:success] = "\"#{@story.title}\" has been merged into this story."
      return redirect_to @story.merged_into_story.comments_path
    end

    raise ActionController::RoutingError, 'story gone' unless @story.can_be_seen_by_user?(@user)

    @comments = get_arranged_comments_from_cache(params[:id]) do
      @story.merged_comments
        .includes(:user, :story, :hat, votes: :user)
        .arrange_for_user(@user)
    end

    @title = @story.title
    @short_url = @story.short_id_url

    respond_to do |format|
      format.html do
        @comment = @story.comments.build

        @meta_tags = {
          'twitter:card' => 'summary',
          'twitter:site' => Rails.application.secrets.twitter_username,
          'twitter:title' => @story.title,
          'twitter:description' => @story.comments_count.to_s + ' ' +
                                   'comment'.pluralize(@story.comments_count),
          'twitter:image' => Rails.application.root_url +
                             'apple-touch-icon-144.png'
        }

        if @story.user.twitter_username.present?
          @meta_tags['twitter:creator'] = '@' + @story.user.twitter_username
        end

        load_user_votes

        render action: 'show'
      end
      format.json do
        render json: @story.as_json(with_comments: @comments)
      end
    end
  end

  def suggest
    unless @story.can_have_suggestions_from_user?(@user)
      flash[:error] = 'You are not allowed to offer suggestions on that story.'
      return redirect_to @story.comments_path
    end

    if (suggested_tags = @story.suggested_taggings.where(user_id: @user.id)).any?
      @story.tags_a = suggested_tags.map { |st| st.tag.tag }
    end
    if (tt = @story.suggested_titles.where(user_id: @user.id).first)
      @story.title = tt.title
    end
  end

  def submit_suggestions
    unless @story.can_have_suggestions_from_user?(@user)
      flash[:error] = 'You are not allowed to offer suggestions on that story.'
      return redirect_to @story.comments_path
    end

    ostory = @story.dup

    @story.title = params[:story][:title]
    if @story.valid?
      dsug = false
      if @story.title != ostory.title
        @story.save_suggested_title_for_user!(@story.title, @user)
        dsug = true
      end

      sugtags = params[:story][:tags_a].reject { |t| t.to_s.strip == '' }.sort
      if @story.tags_a.sort != sugtags
        @story.save_suggested_tags_a_for_user!(sugtags, @user)
        dsug = true
      end

      if dsug
        ostory = @story.reload
        flash[:success] = 'Your suggested changes have been noted.'
      end
      redirect_to ostory.comments_path
    else
      render action: 'suggest'
    end
  end

  def undelete
    unless @story.is_editable_by_user?(@user) &&
           @story.is_undeletable_by_user?(@user)
      flash[:error] = 'You cannot edit that story.'
      return redirect_to '/'
    end

    @story.is_expired = false
    @story.editor = @user
    @story.save(validate: false)

    redirect_to @story.comments_path
  end

  def update
    unless @story.is_editable_by_user?(@user)
      flash[:error] = 'You cannot edit that story.'
      return redirect_to '/'
    end

    @story.is_expired = false
    @story.editor = @user

    @story.attributes = if @story.url_is_editable_by_user?(@user)
                          story_params
                        else
                          story_params.except(:url)
                        end

    if @story.save
      return redirect_to @story.comments_path
    else
      return render action: 'edit'
    end
  end

  def unvote
    unless (story = find_story)
      return render plain: "can't find story", status: :bad_request
    end

    Vote.vote_thusly_on_story_or_comment_for_user_because(
      0, story.id, nil, @user.id, nil
    )

    render plain: 'ok'
  end

  def upvote
    unless (story = find_story)
      return render plain: "can't find story", status: :bad_request
    end

    Vote.vote_thusly_on_story_or_comment_for_user_because(
      1, story.id, nil, @user.id, nil
    )

    render plain: 'ok'
  end

  def downvote
    unless (story = find_story)
      return render plain: "can't find story", status: :bad_request
    end

    unless Vote::STORY_REASONS[params[:reason]]
      return render plain: 'invalid reason', status: :bad_request
    end

    unless @user.can_downvote?(story)
      return render plain: 'not permitted to downvote', status: :bad_request
    end

    Vote.vote_thusly_on_story_or_comment_for_user_because(
      -1, story.id, nil, @user.id, params[:reason]
    )

    render plain: 'ok'
  end

  def hide
    unless (story = find_story)
      return render plain: "can't find story", status: :bad_request
    end

    HiddenStory.hide_story_for_user(story.id, @user.id)
    ReadRibbon.hide_replies_for(story.id, @user.id)

    render plain: 'ok'
  end

  def unhide
    unless (story = find_story)
      return render plain: "can't find story", status: :bad_request
    end

    HiddenStory.where(user_id: @user.id, story_id: story.id).delete_all

    render plain: 'ok'
  end

  def save
    unless (story = find_story)
      return render plain: "can't find story", status: :bad_request
    end

    SavedStory.save_story_for_user(story.id, @user.id)

    render plain: 'ok'
  end

  def unsave
    unless (story = find_story)
      return render plain: "can't find story", status: :bad_request
    end

    SavedStory.where(user_id: @user.id, story_id: story.id).delete_all

    render plain: 'ok'
  end

  def check_url_dupe
    @story = Story.new(story_params)
    @story.check_already_posted

    render partial: 'stories/form_errors', layout: false,
           content_type: 'text/html', locals: { story: @story }
  end

  private

  def get_arranged_comments_from_cache(short_id, &block)
    if Rails.env.development? || @user
      yield
    else
      Rails.cache.fetch("story #{short_id}", expires_in: 60, &block)
    end
  end

  def story_params
    p = params.require(:story).permit(
      :title, :url, :description, :moderation_reason, :seen_previous,
      :merge_story_short_id, :is_unavailable, :user_is_author, tags_a: []
    )

    if @user.is_moderator?
      p
    else
      p.except(:moderation_reason, :merge_story_short_id, :is_unavailable)
    end
  end

  def find_story
    story = Story.where(short_id: params[:story_id]).first
    if @user && story
      story.vote = Vote.where(user_id: @user.id,
                              story_id: story.id, comment_id: nil).first&.vote
    end

    story
  end

  def find_story!
    @story = find_story
    raise ActiveRecord::RecordNotFound unless @story
  end

  def find_user_story
    @story = if @user.is_moderator?
               Story.where(short_id: params[:story_id] || params[:id]).first
             else
               Story.where(user_id: @user.id, short_id: (params[:story_id] || params[:id])).first
             end

    unless @story
      flash[:error] = 'Could not find story or you are not authorized ' \
                      'to manage it.'
      redirect_to '/'
      return false
    end
  end

  def load_user_votes
    if @user
      if (v = Vote.where(user_id: @user.id, story_id: @story.id, comment_id: nil).first)
        @story.vote = { vote: v.vote, reason: v.reason }
      end

      @story.is_hidden_by_cur_user = @story.is_hidden_by_user?(@user)
      @story.is_saved_by_cur_user = @story.is_saved_by_user?(@user)

      @votes = Vote.comment_votes_by_user_for_story_hash(@user.id, @story.id)
      @comments.each do |c|
        c.current_vote = @votes[c.id] if @votes[c.id]
      end
    end
  end

  def verify_user_can_submit_stories
    unless @user.can_submit_stories?
      flash[:error] = 'You are not allowed to submit new stories.'
      redirect_to '/'
    end
  end

  def track_story_reads
    @story = Story.where(short_id: params[:id]).first!
    @ribbon = ReadRibbon.where(user: @user, story: @story).first_or_create
    yield
    @ribbon.touch
  end
end
