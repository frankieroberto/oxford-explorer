class InstitutionsController < ApplicationController

  def show
    @institution = Institution.find(params[:id])
  end

  def index
    @institutions = Institution.all.select {|i| i.collections.size > 0}
  end

end
