require 'csv'

class CollectionsController < ApplicationController

  def index
    @collections = Collection.all
  end


  def show
    @collection = Collection.find(params[:id])
  end

  def json
    @collection_data = Collection.all
    @collection_data = @collection_data.sort_by(&:institution_id)
    render json: @collection_data.to_json
  end

end
