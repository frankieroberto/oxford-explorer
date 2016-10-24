class SuperfieldsController < ApplicationController


  def index

    @superfield = params[:superfield]

    @superfield = "#{@superfield}.raw" if ['gfs_author', 'gfs_item_type', 'gfs_subject'].include?(@superfield)

    @aggregations = ThingAggregation.new(@superfield, 100).aggregation

  end


  def show
    @id = params[:id]
    @superfield = params[:superfield]


    thing_query = ThingQuery.new(@superfield, @id)

    @things_count = thing_query.things_count
    @things = thing_query.things

    @things_in_collections = thing_query.things_in_collections
    @things_by_item_type = thing_query.things_by_item_type
    @things_by_authors = thing_query.things_by_authors
    @things_by_subjects = thing_query.things_by_subjects
    @things_by_institution = thing_query.things_by_institution


    additional_collections = []

    if @superfield == 'gfs_subject'

      additional_collections += additional_collections =  Collection.all.select {|collection| collection.subjects.include?(@id) }

    elsif @superfield == 'gfs_item_type'

      additional_collections += Collection.all.select {|collection| collection.types_of_things.collect(&:name).include?(@id) }

    elsif @superfield == 'gfs_author'

      additional_collections += Collection.all.select {|collection| collection.people.include?(@id) }

    end

    additional_collections.each do |collection|

      if !@things_in_collections.collect(&:id).include?(collection.id)
        @things_in_collections << OpenStruct.new(collection: collection, count: nil)
      end

    end



    @min_pubyear = thing_query.min_pubyear&.to_i
    @max_pubyear = thing_query.max_pubyear&.to_i

  end
end
