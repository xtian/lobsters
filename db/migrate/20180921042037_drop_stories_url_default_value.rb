# frozen_string_literal: true

class DropStoriesUrlDefaultValue < ActiveRecord::Migration[5.2]
  def up
    change_column :stories, :url, :string, limit: 250, default: nil, null: true
  end

  def down
    change_column :stories, :url, :string, limit: 250, default: '', null: false
  end
end
