# frozen_string_literal: true

class Keystore < ApplicationRecord
  self.primary_key = 'key'

  validates :key, presence: true

  def self.get(key)
    find_by(key: key)
  end

  def self.value_for(key)
    find_by(key: key).try(:value)
  end

  def self.put(key, value)
    if Keystore.connection.adapter_name.match?(/Mysql/)
      Keystore.connection.execute("INSERT INTO #{Keystore.table_name} (" \
        "`key`, `value`) VALUES (#{q(key)}, #{q(value)}) ON DUPLICATE KEY " \
        "UPDATE `value` = #{q(value)}")
    else
      kv = find_or_create_key_for_update(key, value)
      kv.value = value
      kv.save!
    end

    true
  end

  def self.increment_value_for(key, amount = 1)
    incremented_value_for(key, amount)
  end

  def self.incremented_value_for(key, amount = 1)
    Keystore.transaction do
      if Keystore.connection.adapter_name.match?(/Mysql/)
        Keystore.connection.execute("INSERT INTO #{Keystore.table_name} (" \
          "`key`, `value`) VALUES (#{q(key)}, #{q(amount)}) ON DUPLICATE KEY " \
          "UPDATE `value` = `value` + #{q(amount)}")
      else
        kv = find_or_create_key_for_update(key, 0)
        kv.value = kv.value.to_i + amount
        kv.save!
        return kv.value
      end

      value_for(key)
    end
  end

  def self.find_or_create_key_for_update(key, init = nil)
    loop do
      found = lock(true).find_by(key: key)
      return found if found

      begin
        create! do |kv|
          kv.key = key
          kv.value = init
          kv.save!
        end
      rescue ActiveRecord::RecordNotUnique
        nil
      end
    end
  end

  def self.decrement_value_for(key, amount = -1)
    increment_value_for(key, amount)
  end

  def self.decremented_value_for(key, amount = -1)
    incremented_value_for(key, amount)
  end
end
