# frozen_string_literal: true

class RemoveUsersMailingListMode < ActiveRecord::Migration[5.2]
  def up
    change_table :users, bulk: true do |t|
      t.remove :mailing_list_mode
      t.remove :mailing_list_token
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.integer :mailing_list_mode, null: false, default: 0
      t.string :mailing_list_token, limit: 75

      t.index :mailing_list_mode, name: 'mailing_list_enabled'
      t.index :mailing_list_token, name: 'mailing_list_token', unique: true
    end
  end
end
