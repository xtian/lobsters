# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_09_21_042037) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "comments", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_id", limit: 10, default: "", null: false
    t.integer "story_id", null: false
    t.integer "user_id", null: false
    t.integer "parent_comment_id"
    t.integer "thread_id"
    t.text "comment", null: false
    t.integer "upvotes", default: 0, null: false
    t.integer "downvotes", default: 0, null: false
    t.decimal "confidence", precision: 20, scale: 19, default: "0.0", null: false
    t.text "markeddown_comment"
    t.boolean "is_deleted", default: false, null: false
    t.boolean "is_moderated", default: false, null: false
    t.boolean "is_from_email", default: false, null: false
    t.integer "hat_id"
    t.index ["confidence"], name: "confidence_idx"
    t.index ["short_id"], name: "short_id", unique: true
    t.index ["story_id", "short_id"], name: "story_id_short_id"
    t.index ["thread_id"], name: "thread_id"
    t.index ["user_id", "story_id", "downvotes", "created_at"], name: "downvote_index"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "hat_requests", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "hat", null: false
    t.string "link", null: false
    t.text "comment", null: false
    t.index ["user_id", "hat"], name: "index_hat_requests_on_user_id_and_hat", unique: true
  end

  create_table "hats", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "granted_by_user_id", null: false
    t.string "hat", null: false
    t.string "link"
    t.boolean "modlog_use", default: false, null: false
    t.datetime "doffed_at"
    t.index ["user_id", "hat"], name: "index_hats_on_user_id_and_hat", unique: true
  end

  create_table "hidden_stories", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "story_id", null: false
    t.index ["user_id", "story_id"], name: "index_hidden_stories_on_user_id_and_story_id", unique: true
  end

  create_table "invitation_requests", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.boolean "is_verified", default: false, null: false
    t.citext "email", null: false
    t.string "name", null: false
    t.text "memo"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_invitation_requests_on_code", unique: true
  end

  create_table "invitations", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.citext "email"
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "memo"
    t.datetime "used_at"
    t.integer "new_user_id"
    t.index ["code"], name: "index_invitations_on_code", unique: true
  end

  create_table "keystores", id: false, force: :cascade do |t|
    t.string "key", limit: 50, default: "", null: false
    t.bigint "value"
    t.index ["key"], name: "key", unique: true
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "author_user_id", null: false
    t.integer "recipient_user_id", null: false
    t.boolean "has_been_read", default: false, null: false
    t.string "subject", limit: 100
    t.text "body"
    t.string "short_id", limit: 30
    t.boolean "deleted_by_author", default: false, null: false
    t.boolean "deleted_by_recipient", default: false, null: false
    t.bigint "hat_id"
    t.index ["hat_id"], name: "index_messages_on_hat_id"
    t.index ["short_id"], name: "random_hash", unique: true
  end

  create_table "mod_notes", force: :cascade do |t|
    t.integer "moderator_user_id", null: false
    t.integer "user_id", null: false
    t.text "note", null: false
    t.text "markeddown_note", null: false
    t.datetime "created_at", null: false
    t.index ["id", "user_id"], name: "index_mod_notes_on_id_and_user_id"
  end

  create_table "moderations", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "moderator_user_id"
    t.integer "story_id"
    t.integer "comment_id"
    t.integer "user_id"
    t.text "action"
    t.text "reason"
    t.boolean "is_from_suggestions", default: false, null: false
    t.integer "tag_id"
    t.index ["created_at"], name: "index_moderations_on_created_at"
  end

  create_table "read_ribbons", force: :cascade do |t|
    t.boolean "is_following", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "story_id", null: false
    t.index ["story_id"], name: "index_read_ribbons_on_story_id"
    t.index ["user_id", "story_id"], name: "index_read_ribbons_on_user_id_and_story_id", unique: true
  end

  create_table "saved_stories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "story_id", null: false
    t.index ["user_id", "story_id"], name: "index_saved_stories_on_user_id_and_story_id", unique: true
  end

  create_table "stories", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "user_id", null: false
    t.string "url", limit: 250
    t.string "title", limit: 150, default: "", null: false
    t.text "description"
    t.string "short_id", limit: 6, default: "", null: false
    t.boolean "is_expired", default: false, null: false
    t.integer "upvotes", default: 0, null: false
    t.integer "downvotes", default: 0, null: false
    t.boolean "is_moderated", default: false, null: false
    t.decimal "hotness", precision: 20, scale: 10, default: "0.0", null: false
    t.text "markeddown_description"
    t.text "story_cache"
    t.integer "comments_count", default: 0, null: false
    t.integer "merged_story_id"
    t.datetime "unavailable_at"
    t.string "twitter_id", limit: 20
    t.boolean "user_is_author", default: false, null: false
    t.index ["created_at"], name: "index_stories_on_created_at"
    t.index ["hotness"], name: "hotness_idx"
    t.index ["is_expired", "is_moderated"], name: "is_idxes"
    t.index ["is_expired"], name: "index_stories_on_is_expired"
    t.index ["is_moderated"], name: "index_stories_on_is_moderated"
    t.index ["merged_story_id"], name: "index_stories_on_merged_story_id"
    t.index ["short_id"], name: "unique_short_id", unique: true
    t.index ["twitter_id"], name: "index_stories_on_twitter_id"
    t.index ["url"], name: "url"
    t.index ["user_id"], name: "index_stories_on_user_id"
  end

  create_table "suggested_taggings", id: :serial, force: :cascade do |t|
    t.integer "story_id", null: false
    t.integer "tag_id", null: false
    t.integer "user_id", null: false
    t.index ["story_id", "tag_id", "user_id"], name: "index_suggested_taggings_on_story_id_and_tag_id_and_user_id", unique: true
  end

  create_table "suggested_titles", id: :serial, force: :cascade do |t|
    t.integer "story_id", null: false
    t.integer "user_id", null: false
    t.string "title", limit: 150, default: "", null: false
    t.index ["story_id", "user_id"], name: "index_suggested_titles_on_story_id_and_user_id", unique: true
  end

  create_table "tag_filters", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "tag_id", null: false
    t.index ["user_id", "tag_id"], name: "user_tag_idx"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "story_id", null: false
    t.integer "tag_id", null: false
    t.index ["story_id", "tag_id"], name: "story_id_tag_id", unique: true
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "tag", limit: 25, null: false
    t.string "description", limit: 100
    t.boolean "privileged", default: false, null: false
    t.boolean "is_media", default: false, null: false
    t.boolean "inactive", default: false, null: false
    t.float "hotness_mod", default: 0.0, null: false
    t.index ["tag"], name: "tag", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username", limit: 50
    t.citext "email"
    t.string "password_digest", limit: 75
    t.datetime "created_at", null: false
    t.boolean "is_admin", default: false, null: false
    t.string "password_reset_token", limit: 75
    t.string "session_token", limit: 75, default: "", null: false
    t.text "about"
    t.integer "invited_by_user_id"
    t.boolean "is_moderator", default: false, null: false
    t.boolean "pushover_mentions", default: false, null: false
    t.string "rss_token", limit: 75
    t.string "mailing_list_token", limit: 75
    t.integer "mailing_list_mode", default: 0, null: false
    t.integer "karma", default: 0, null: false
    t.datetime "banned_at"
    t.integer "banned_by_user_id"
    t.string "banned_reason", limit: 200
    t.datetime "deleted_at"
    t.datetime "disabled_invite_at"
    t.integer "disabled_invite_by_user_id"
    t.string "disabled_invite_reason", limit: 200
    t.text "settings"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["mailing_list_mode"], name: "mailing_list_enabled"
    t.index ["mailing_list_token"], name: "mailing_list_token", unique: true
    t.index ["password_reset_token"], name: "password_reset_token", unique: true
    t.index ["rss_token"], name: "rss_token", unique: true
    t.index ["session_token"], name: "session_hash", unique: true
    t.index ["username"], name: "username", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "story_id", null: false
    t.integer "comment_id"
    t.integer "vote", limit: 2, null: false
    t.string "reason", limit: 1
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_votes_on_comment_id"
    t.index ["user_id", "comment_id"], name: "user_id_comment_id"
    t.index ["user_id", "story_id"], name: "user_id_story_id"
  end

  add_foreign_key "comments", "comments", column: "parent_comment_id"
  add_foreign_key "comments", "stories"
  add_foreign_key "comments", "users"
  add_foreign_key "hat_requests", "users", on_delete: :cascade
  add_foreign_key "hats", "users", column: "granted_by_user_id"
  add_foreign_key "hats", "users", on_delete: :cascade
  add_foreign_key "hidden_stories", "stories", on_delete: :cascade
  add_foreign_key "hidden_stories", "users", on_delete: :cascade
  add_foreign_key "invitations", "users", column: "new_user_id"
  add_foreign_key "invitations", "users", on_delete: :cascade
  add_foreign_key "messages", "hats"
  add_foreign_key "messages", "users", column: "author_user_id"
  add_foreign_key "messages", "users", column: "recipient_user_id"
  add_foreign_key "mod_notes", "users"
  add_foreign_key "mod_notes", "users", column: "moderator_user_id"
  add_foreign_key "moderations", "comments", on_delete: :cascade
  add_foreign_key "moderations", "stories"
  add_foreign_key "moderations", "tags"
  add_foreign_key "moderations", "users"
  add_foreign_key "moderations", "users", column: "moderator_user_id"
  add_foreign_key "read_ribbons", "stories", on_delete: :cascade
  add_foreign_key "read_ribbons", "users", on_delete: :cascade
  add_foreign_key "saved_stories", "stories", on_delete: :cascade
  add_foreign_key "saved_stories", "users", on_delete: :cascade
  add_foreign_key "stories", "stories", column: "merged_story_id", on_delete: :nullify
  add_foreign_key "stories", "users"
  add_foreign_key "suggested_taggings", "stories", on_delete: :cascade
  add_foreign_key "suggested_taggings", "tags", on_delete: :cascade
  add_foreign_key "suggested_taggings", "users", on_delete: :cascade
  add_foreign_key "suggested_titles", "stories", on_delete: :cascade
  add_foreign_key "suggested_titles", "users", on_delete: :cascade
  add_foreign_key "tag_filters", "tags", on_delete: :cascade
  add_foreign_key "tag_filters", "users", on_delete: :cascade
  add_foreign_key "taggings", "stories", on_delete: :cascade
  add_foreign_key "taggings", "tags", on_delete: :cascade
  add_foreign_key "users", "users", column: "banned_by_user_id"
  add_foreign_key "users", "users", column: "disabled_invite_by_user_id"
  add_foreign_key "users", "users", column: "invited_by_user_id"
  add_foreign_key "votes", "comments", on_delete: :cascade
  add_foreign_key "votes", "stories", on_delete: :cascade
  add_foreign_key "votes", "users", on_delete: :cascade

  create_view "replying_comments",  sql_definition: <<-SQL
      SELECT read_ribbons.user_id,
      comments.id AS comment_id,
      read_ribbons.story_id,
      comments.parent_comment_id,
      comments.created_at AS comment_created_at,
      parent_comments.user_id AS parent_comment_author_id,
      comments.user_id AS comment_author_id,
      stories.user_id AS story_author_id,
      (read_ribbons.updated_at < comments.created_at) AS is_unread,
      ( SELECT votes.vote
             FROM votes
            WHERE ((votes.user_id = read_ribbons.user_id) AND (votes.comment_id = comments.id))) AS current_vote_vote,
      ( SELECT votes.reason
             FROM votes
            WHERE ((votes.user_id = read_ribbons.user_id) AND (votes.comment_id = comments.id))) AS current_vote_reason
     FROM (((read_ribbons
       JOIN comments ON ((comments.story_id = read_ribbons.story_id)))
       JOIN stories ON ((stories.id = comments.story_id)))
       LEFT JOIN comments parent_comments ON ((parent_comments.id = comments.parent_comment_id)))
    WHERE ((read_ribbons.is_following = true) AND (comments.user_id <> read_ribbons.user_id) AND (comments.is_deleted = false) AND (comments.is_moderated = false) AND ((parent_comments.user_id = read_ribbons.user_id) OR ((parent_comments.user_id IS NULL) AND (stories.user_id = read_ribbons.user_id))) AND ((comments.upvotes - comments.downvotes) >= 0) AND ((parent_comments.id IS NULL) OR ((parent_comments.upvotes - parent_comments.downvotes) >= 0)) AND ((stories.upvotes - stories.downvotes) >= 0));
  SQL

end
