# frozen_string_literal: true

class AddSomeNonNullConstraints < ActiveRecord::Migration[5.2]
  def up
    drop_view :replying_comments

    change_column :comments, :updated_at, :datetime, null: false

    change_table :hat_requests, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :hat, :string
        tt.change :link, :string
        tt.change :comment, :text
        tt.change :created_at, :datetime
        tt.change :updated_at, :datetime
        tt.change :user_id, :integer
      end
    end

    change_table :hats, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :created_at, :datetime
        tt.change :granted_by_user_id, :integer
        tt.change :updated_at, :datetime
        tt.change :user_id, :integer
      end
    end

    change_table :hidden_stories, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :story_id, :integer
        tt.change :user_id, :integer
      end
    end

    change_table :invitation_requests, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :name, :string
        tt.change :email, :citext
      end
    end

    change_table :messages, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :created_at, :datetime
        tt.change :author_user_id, :integer
        tt.change :recipient_user_id, :integer
      end
    end

    change_table :read_ribbons, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :story_id, :bigint
        tt.change :user_id, :bigint
      end
    end

    change_table :saved_stories, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :story_id, :integer
        tt.change :user_id, :integer
      end
    end

    change_table :stories, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :created_at, :datetime
        tt.change :user_id, :integer
      end
    end

    change_table :suggested_taggings, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :story_id, :integer
        tt.change :tag_id, :integer
        tt.change :user_id, :integer
      end
    end

    change_table :suggested_titles, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :story_id, :integer
        tt.change :user_id, :integer
      end
    end

    change_table :tag_filters, bulk: true do |t|
      t.with_options null: false do |tt|
        tt.change :tag_id, :integer
        tt.change :user_id, :integer
      end
    end

    change_column :users, :created_at, :datetime, null: false

    create_view :replying_comments, version: 7
  end

  def down
    drop_view :replying_comments

    change_column :comments, :updated_at, :datetime, null: true

    change_table :hat_requests, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :hat, :string
        tt.change :link, :string
        tt.change :comment, :text
        tt.change :created_at, :datetime
        tt.change :updated_at, :datetime
        tt.change :user_id, :integer
      end
    end

    change_table :hats, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :created_at, :datetime
        tt.change :granted_by_user_id, :integer
        tt.change :updated_at, :datetime
        tt.change :user_id, :integer
      end
    end

    change_table :hidden_stories, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :story_id, :integer
        tt.change :user_id, :integer
      end
    end

    change_table :invitation_requests, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :name, :string
        tt.change :email, :citext
      end
    end

    change_table :messages, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :created_at, :datetime
        tt.change :author_user_id, :integer
        tt.change :recipient_user_id, :integer
      end
    end

    change_table :read_ribbons, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :story_id, :bigint
        tt.change :user_id, :bigint
      end
    end

    change_table :saved_stories, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :story_id, :integer
        tt.change :user_id, :integer
      end
    end

    change_table :stories, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :created_at, :datetime
        tt.change :user_id, :integer
      end
    end

    change_table :suggested_taggings, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :story_id, :integer
        tt.change :tag_id, :integer
        tt.change :user_id, :integer
      end
    end

    change_table :suggested_titles, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :story_id, :integer
        tt.change :user_id, :integer
      end
    end

    change_table :tag_filters, bulk: true do |t|
      t.with_options null: true do |tt|
        tt.change :tag_id, :integer
        tt.change :user_id, :integer
      end
    end

    change_column :users, :created_at, :datetime, null: true

    create_view :replying_comments, version: 7
  end
end
