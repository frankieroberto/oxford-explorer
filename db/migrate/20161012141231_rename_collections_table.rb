class RenameCollectionsTable < ActiveRecord::Migration[5.0]
  def change
    rename_table :collections, :sub_collections
    rename_column :people_in_collections, :collection_id, :sub_collection_id
  end
end
