class AddSomeNonNullConstraints < ActiveRecord::Migration[5.2]
  def up
    drop_view :replying_comments

    change_column :comments, :updated_at, :datetime, null: false

    change_column :hat_requests, :hat, :string, null: false
    change_column :hat_requests, :link, :string, null: false
    change_column :hat_requests, :comment, :text, null: false
    change_column :hat_requests, :created_at, :datetime, null: false
    change_column :hat_requests, :updated_at, :datetime, null: false
    change_column :hat_requests, :user_id, :integer, null: false

    change_column :hats, :created_at, :datetime, null: false
    change_column :hats, :granted_by_user_id, :integer, null: false
    change_column :hats, :updated_at, :datetime, null: false
    change_column :hats, :user_id, :integer, null: false

    change_column :hidden_stories, :story_id, :integer, null: false
    change_column :hidden_stories, :user_id, :integer, null: false

    change_column :invitation_requests, :name, :string, null: false
    change_column :invitation_requests, :email, :citext, null: false

    change_column :messages, :created_at, :datetime, null: false
    change_column :messages, :author_user_id, :integer, null: false
    change_column :messages, :recipient_user_id, :integer, null: false

    change_column :read_ribbons, :story_id, :bigint, null: false
    change_column :read_ribbons, :user_id, :bigint, null: false

    change_column :saved_stories, :story_id, :integer, null: false
    change_column :saved_stories, :user_id, :integer, null: false

    change_column :stories, :created_at, :datetime, null: false
    change_column :stories, :user_id, :integer, null: false

    change_column :suggested_taggings, :story_id, :integer, null: false
    change_column :suggested_taggings, :tag_id, :integer, null: false
    change_column :suggested_taggings, :user_id, :integer, null: false

    change_column :suggested_titles, :story_id, :integer, null: false
    change_column :suggested_titles, :user_id, :integer, null: false

    change_column :tag_filters, :tag_id, :integer, null: false
    change_column :tag_filters, :user_id, :integer, null: false

    change_column :users, :created_at, :datetime, null: false

    create_view :replying_comments, version: 7
  end

  def down
    drop_view :replying_comments

    change_column :comments, :updated_at, :datetime, null: true

    change_column :hat_requests, :hat, :string, null: true
    change_column :hat_requests, :link, :string, null: true
    change_column :hat_requests, :comment, :text, null: true
    change_column :hat_requests, :created_at, :datetime, null: true
    change_column :hat_requests, :updated_at, :datetime, null: true
    change_column :hat_requests, :user_id, :integer, null: true

    change_column :hats, :created_at, :datetime, null: true
    change_column :hats, :granted_by_user_id, :integer, null: true
    change_column :hats, :updated_at, :datetime, null: true
    change_column :hats, :user_id, :integer, null: true

    change_column :hidden_stories, :story_id, :integer, null: true
    change_column :hidden_stories, :user_id, :integer, null: true

    change_column :invitation_requests, :name, :string, null: true
    change_column :invitation_requests, :email, :citext, null: true

    change_column :messages, :created_at, :datetime, null: true
    change_column :messages, :author_user_id, :integer, null: true
    change_column :messages, :recipient_user_id, :integer, null: true

    change_column :read_ribbons, :story_id, :bigint, null: true
    change_column :read_ribbons, :user_id, :bigint, null: true

    change_column :saved_stories, :story_id, :integer, null: true
    change_column :saved_stories, :user_id, :integer, null: true

    change_column :stories, :created_at, :datetime, null: true
    change_column :stories, :user_id, :integer, null: true

    change_column :suggested_taggings, :story_id, :integer, null: true
    change_column :suggested_taggings, :tag_id, :integer, null: true
    change_column :suggested_taggings, :user_id, :integer, null: true

    change_column :suggested_titles, :story_id, :integer, null: true
    change_column :suggested_titles, :user_id, :integer, null: true

    change_column :tag_filters, :tag_id, :integer, null: true
    change_column :tag_filters, :user_id, :integer, null: true

    change_column :users, :created_at, :datetime, null: true

    create_view :replying_comments, version: 7
  end
end
