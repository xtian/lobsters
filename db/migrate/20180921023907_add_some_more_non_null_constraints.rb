# frozen_string_literal: true

class AddSomeMoreNonNullConstraints < ActiveRecord::Migration[5.2]
  def up
    drop_view :replying_comments

    change_table :comments, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :is_deleted, :boolean, default: false
        tt.change :is_moderated, :boolean, default: false
        tt.change :is_from_email, :boolean, default: false
      end
    end

    change_column :hats, :modlog_use, :boolean, default: false, null: false

    change_table :invitation_requests, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :code, :string
        tt.change :is_verified, :boolean, default: false
      end
    end

    change_column :invitations, :code, :string, null: false

    change_table :messages, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :has_been_read, :boolean, default: false
        tt.change :deleted_by_author, :boolean, default: false
        tt.change :deleted_by_recipient, :boolean, default: false
      end
    end

    change_column :moderations, :is_from_suggestions, :boolean, default: false, null: false

    change_column :read_ribbons, :is_following, :boolean, default: true, null: false

    change_table :stories, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :url, :string, default: '', limit: 250
        tt.change :user_is_author, :boolean, default: false
      end
    end

    change_table :tags, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :privileged, :boolean, default: false
        tt.change :is_media, :boolean, default: false
        tt.change :inactive, :boolean, default: false
        tt.change :hotness_mod, :float, default: 0.0
      end
    end

    change_table :users, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :is_admin, :boolean, default: false
        tt.change :is_moderator, :boolean, default: false
        tt.change :pushover_mentions, :boolean, default: false
        tt.change :mailing_list_mode, :integer, default: 0
      end
    end

    create_view :replying_comments, version: 7
  end

  def down
    drop_view :replying_comments

    change_table :comments, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :is_deleted, :boolean, default: false
        tt.change :is_moderated, :boolean, default: false
        tt.change :is_from_email, :boolean, default: false
      end
    end

    change_column :hats, :modlog_use, :boolean, default: false, null: false

    change_table :invitation_requests, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :code, :string
        tt.change :is_verified, :boolean, default: false
      end
    end

    change_column :invitations, :code, :string, null: false

    change_table :messages, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :has_been_read, :boolean, default: false
        tt.change :deleted_by_author, :boolean, default: false
        tt.change :deleted_by_recipient, :boolean, default: false
      end
    end

    change_column :moderations, :is_from_suggestions, :boolean, default: false, null: false

    change_column :read_ribbons, :is_following, :boolean, default: true, null: false

    change_table :stories, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :url, :string, default: '', limit: 250
        tt.change :user_is_author, :boolean, default: false
      end
    end

    change_table :tags, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :privileged, :boolean, default: false
        tt.change :is_media, :boolean, default: false
        tt.change :inactive, :boolean, default: false
        tt.change :hotness_mod, :float, default: 0.0
      end
    end

    change_table :users, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :is_admin, :boolean, default: false
        tt.change :is_moderator, :boolean, default: false
        tt.change :pushover_mentions, :boolean, default: false
        tt.change :mailing_list_mode, :integer, default: 0
      end
    end

    create_view :replying_comments, version: 7
  end
end
