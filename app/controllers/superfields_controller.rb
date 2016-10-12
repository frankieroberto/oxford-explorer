class SuperfieldsController < ApplicationController

  def show
    @id = params[:id]
    @superfield = params[:superfield]
  end
end
