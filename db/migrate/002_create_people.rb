require 'active_record'

class CreatePeople < ActiveRecord::Migration
  def up

    enable_extension 'hstore' unless extension_enabled?('hstore')

    create_table :people do |t|
      t.text :name, null: false
      t.text :born
      t.text :died
      t.text :other, array: true
      t.hstore :identifiers, null: false, default: {}
    end

  end
end
