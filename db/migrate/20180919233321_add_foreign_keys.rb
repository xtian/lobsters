# frozen_string_literal: true

class AddForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :comments, :comments, column: :parent_comment_id
    add_foreign_key :comments, :stories
    add_foreign_key :comments, :users

    add_foreign_key :hat_requests, :users, on_delete: :cascade

    add_foreign_key :hats, :users, column: :granted_by_user_id
    add_foreign_key :hats, :users, on_delete: :cascade

    add_foreign_key :hidden_stories, :stories, on_delete: :cascade
    add_foreign_key :hidden_stories, :users, on_delete: :cascade

    add_foreign_key :invitations, :users, column: :new_user_id
    add_foreign_key :invitations, :users, on_delete: :cascade

    add_foreign_key :messages, :hats
    add_foreign_key :messages, :users, column: :author_user_id
    add_foreign_key :messages, :users, column: :recipient_user_id

    add_foreign_key :mod_notes, :users, column: :moderator_user_id

    add_foreign_key :moderations, :comments, on_delete: :cascade
    add_foreign_key :moderations, :stories
    add_foreign_key :moderations, :tags
    add_foreign_key :moderations, :users
    add_foreign_key :moderations, :users, column: :moderator_user_id

    add_foreign_key :read_ribbons, :stories, on_delete: :cascade
    add_foreign_key :read_ribbons, :users, on_delete: :cascade

    add_foreign_key :saved_stories, :stories, on_delete: :cascade
    add_foreign_key :saved_stories, :users, on_delete: :cascade

    add_foreign_key :stories, :stories, column: :merged_story_id, on_delete: :nullify
    add_foreign_key :stories, :users

    add_foreign_key :suggested_taggings, :stories, on_delete: :cascade
    add_foreign_key :suggested_taggings, :tags, on_delete: :cascade
    add_foreign_key :suggested_taggings, :users, on_delete: :cascade

    add_foreign_key :suggested_titles, :stories, on_delete: :cascade
    add_foreign_key :suggested_titles, :users, on_delete: :cascade

    add_foreign_key :tag_filters, :tags, on_delete: :cascade
    add_foreign_key :tag_filters, :users, on_delete: :cascade

    add_foreign_key :taggings, :stories, on_delete: :cascade
    add_foreign_key :taggings, :tags, on_delete: :cascade

    add_foreign_key :users, :users, column: :banned_by_user_id
    add_foreign_key :users, :users, column: :disabled_invite_by_user_id
    add_foreign_key :users, :users, column: :invited_by_user_id

    add_foreign_key :votes, :comments, on_delete: :cascade
    add_foreign_key :votes, :stories, on_delete: :cascade
    add_foreign_key :votes, :users, on_delete: :cascade
  end
end
