class Collection < ActiveRecord::Base
  has_many :people_in_collections, class_name: :PersonInCollection
  has_many :people, through: :people_in_collections
end