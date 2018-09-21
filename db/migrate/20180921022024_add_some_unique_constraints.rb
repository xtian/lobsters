class AddSomeUniqueConstraints < ActiveRecord::Migration[5.2]
  def change
    add_index :hat_requests, [:user_id, :hat], unique: true

    add_index :hats, [:user_id, :hat], unique: true

    add_index :invitation_requests, :code, unique: true

    add_index :invitations, :code, unique: true

    remove_index :read_ribbons, :user_id
    add_index :read_ribbons, [:user_id, :story_id], unique: true

    add_index :suggested_taggings, [:story_id, :tag_id, :user_id], unique: true

    add_index :suggested_titles, [:story_id, :user_id], unique: true
  end
end
