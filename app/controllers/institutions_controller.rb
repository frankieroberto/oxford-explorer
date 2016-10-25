class InstitutionsController < ApplicationController

  def show
    @institution = Institution.find(params[:id])
  end

  def index
    @institutions = Institution.all
  end

end
