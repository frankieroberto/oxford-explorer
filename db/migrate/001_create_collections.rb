require 'active_record'

class CreateCollections < ActiveRecord::Migration
  def up
    create_table :collections do |t|
      t.text :name, null: false
      t.text :department
      t.text :extent
      t.text :abstract
      t.text :dates
      t.text :unitid
      t.text :acquisition_info
      t.text :preferred_citation
      t.text :other_finding_aids
      t.text :related_material
      t.text :arrangement
    end

  end
end
