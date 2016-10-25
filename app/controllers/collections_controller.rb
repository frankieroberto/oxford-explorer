require 'csv'

class CollectionsController < ApplicationController

  def index
    @show = params[:show]
    @collections = Collection.all
  end


  def show
    @collection = Collection.find(params[:id])

    @things = ThingQuery.new('gfs_collection_id', @collection.id, 'exact').things

  end

  def json
    @collection_data = Collection.all
    if params[:sort] == 'dig_metadata_size'
      @collection_data = @collection_data.sort_by(&:digitized_metadata_size_int).reverse
    else
      @collection_data = @collection_data.sort_by(&:institution_id)
    end
    render json: @collection_data.collect { |collection|
      {
        id: collection.id,
        name: collection.name,
        department: collection.department,
        size_int: collection.size_int,
        digitized_metadata_size_int: collection.digitized_metadata_size_int,
        digitized_size_int: collection.digitized_size_int,
        institution_id: collection.institution_id,
        subjects: collection.subjects,
        super_academic_departments: collection.divisions,
        academic_departments: collection.academic_departments,
        types_of_things: collection.types_of_things.collect {|c| c&.name },
        super_types_of_things: collection.types_of_things.collect {|c| c&.super_type&.name }.flatten.uniq

      }
    }
  end

end
