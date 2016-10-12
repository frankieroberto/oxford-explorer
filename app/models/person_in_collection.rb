class PersonInCollection < ActiveRecord::Base;

  self.table_name = "people_in_collections"

  belongs_to :sub_collection
  belongs_to :person, counter_cache: :collections_count

end