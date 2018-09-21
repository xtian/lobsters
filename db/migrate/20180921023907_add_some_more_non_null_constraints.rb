class AddSomeMoreNonNullConstraints < ActiveRecord::Migration[5.2]
  def up
    drop_view :replying_comments

    change_column :comments, :is_deleted, :boolean, default: false, null: false
    change_column :comments, :is_moderated, :boolean, default: false, null: false
    change_column :comments, :is_from_email, :boolean, default: false, null: false

    change_column :hats, :modlog_use, :boolean, default: false, null: false

    change_column :invitation_requests, :code, :string, null: false
    change_column :invitation_requests, :is_verified, :boolean, default: false, null: false

    change_column :invitations, :code, :string, null: false

    change_column :messages, :has_been_read, :boolean, default: false, null: false
    change_column :messages, :deleted_by_author, :boolean, default: false, null: false
    change_column :messages, :deleted_by_recipient, :boolean, default: false, null: false

    change_column :moderations, :is_from_suggestions, :boolean, default: false, null: false

    change_column :read_ribbons, :is_following, :boolean, default: true, null: false

    change_column :stories, :url, :string, default: "", limit: 250, null: false
    change_column :stories, :user_is_author, :boolean, default: false, null: false

    change_column :tags, :privileged, :boolean, default: false, null: false
    change_column :tags, :is_media, :boolean, default: false, null: false
    change_column :tags, :inactive, :boolean, default: false, null: false
    change_column :tags, :hotness_mod, :float, default: 0.0, null: false

    change_column :users, :is_admin, :boolean, default: false, null: false
    change_column :users, :is_moderator, :boolean, default: false, null: false
    change_column :users, :pushover_mentions, :boolean, default: false, null: false
    change_column :users, :mailing_list_mode, :integer, default: 0, null: false

    create_view :replying_comments, version: 7
  end

  def down
    drop_view :replying_comments

    change_column :comments, :is_deleted, :boolean, default: false, null: true
    change_column :comments, :is_moderated, :boolean, default: false, null: true
    change_column :comments, :is_from_email, :boolean, default: false, null: true

    change_column :hats, :modlog_use, :boolean, default: false, null: true

    change_column :invitation_requests, :code, :string, null: true
    change_column :invitation_requests, :is_verified, :boolean, default: false, null: true

    change_column :invitations, :code, :string, null: true

    change_column :messages, :has_been_read, :boolean, default: false, null: true
    change_column :messages, :deleted_by_author, :boolean, default: false, null: true
    change_column :messages, :deleted_by_recipient, :boolean, default: false, null: true

    change_column :moderations, :is_from_suggestions, :boolean, default: false, null: true

    change_column :read_ribbons, :is_following, :boolean, default: true, null: true

    change_column :stories, :url, :string, default: "", limit: 250, null: true
    change_column :stories, :user_is_author, :boolean, default: false, null: true

    change_column :tags, :privileged, :boolean, default: false, null: true
    change_column :tags, :is_media, :boolean, default: false, null: true
    change_column :tags, :inactive, :boolean, default: false, null: true
    change_column :tags, :hotness_mod, :float, default: 0.0, null: true

    change_column :users, :is_admin, :boolean, default: false, null: true
    change_column :users, :is_moderator, :boolean, default: false, null: true
    change_column :users, :pushover_mentions, :boolean, default: false, null: true
    change_column :users, :mailing_list_mode, :integer, default: 0, null: true

    create_view :replying_comments, version: 7
  end
end
