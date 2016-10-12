require 'active_record'

class Collection < ActiveRecord::Base; end
class Person < ActiveRecord::Base; end

class PersonInCollection < ActiveRecord::Base;

  self.table_name = "people_in_collections"

  belongs_to :collection
  belongs_to :person

end


class CreatePeopleInCollections < ActiveRecord::Migration
  def up


    create_table :people_in_collections do |t|
      t.integer :person_id, null: false
      t.integer :collection_id, null: false
      t.text :as, null: false
    end

    add_column :people, :collections_count, :integer, null: false, default: 0

    add_foreign_key :people_in_collections, :people, on_delete: :cascade
    add_foreign_key :people_in_collections, :collections, on_delete: :cascade

    add_index :people_in_collections, [:person_id, :collection_id], unique: true

  end
end
