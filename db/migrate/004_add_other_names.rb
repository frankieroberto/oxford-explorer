require 'active_record'

class AddOtherNames < ActiveRecord::Migration
  def up

    add_column :people, :other_names, :text, null: false, array: true, default: []

  end
end
