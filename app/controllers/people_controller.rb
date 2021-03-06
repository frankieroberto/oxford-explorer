class PeopleController < ApplicationController

  def show
    @id = params[:id]
    @superfield = params[:superfield]

    thing_query = ThingQuery.new('gfs_author', @id)

    @things_count = thing_query.things_count
    @things = thing_query.things

    @things_in_collections = thing_query.things_in_collections
    @things_by_item_type = thing_query.things_by_item_type
    @things_by_authors = thing_query.things_by_authors
    @things_by_subjects = thing_query.things_by_subjects
    @things_by_institution = thing_query.things_by_institution


    additional_collections = Collection.all.select {|collection| collection.people.include?(@id) }

    additional_collections.each do |collection|
      if !@things_in_collections.collect(&:id).include?(collection.id)
        @things_in_collections << OpenStruct.new(collection: collection, count: nil)
      end
    end

    @min_pubyear = thing_query.min_pubyear&.to_i
    @max_pubyear = thing_query.max_pubyear&.to_i
  end

end
