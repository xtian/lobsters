# frozen_string_literal: true

class AddUniqueIndexToUsersEmail < ActiveRecord::Migration[5.2]
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS citext;'

    change_column :invitation_requests, :email, :citext
    change_column :invitations, :email, :citext
    change_column :users, :email, :citext

    add_index :users, :email, unique: true
  end

  def down
    change_column :invitation_requests, :email, :string
    change_column :invitations, :email, :string
    change_column :users, :email, :string

    remove_index :users, :email

    execute 'DROP EXTENSION IF EXISTS citext;'
  end
end
