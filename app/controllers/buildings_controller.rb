# frozen_string_literal: true

class BuildingsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_building, only: %i[show destroy]
  before_action :init_building, only: %i[new create]
  before_action :edit_building, only: %i[edit update]
  before_action -> { check_authorize(@building, controller_name) }, only: %i[new create edit update destroy]

  # GET /buildings
  def index
    @q = Building.all.order(id: :desc).includes(:area).ransack(params[:q])
    @buildings = @q.result.page(params[:page])
    respond_with(@buildings)
  end

  # GET /buildings/1
  def show
    respond_with(@building)
  end

  # GET /buildings/new
  def new
    respond_with(@building)
  end

  # GET /buildings/1/edit
  def edit
    respond_with(@building)
  end

  # POST /buildings
  def create
    @building.save
    respond_with(@building)
  end

  # PATCH/PUT /buildings/1
  def update
    @building.save
    respond_with(@building)
  end

  # DELETE /buildings/1
  def destroy
    @building.destroy
    respond_with(@building, action: :show)
  end

  private

  def set_building
    @building = Building.with_deleted.find(params[:id])
  end

  def init_building
    attributes = params[:building].blank? ? {} : building_params
    @building = Building.new attributes
  end

  def edit_building
    set_building
    return if params[:building].blank?

    @building.attributes = building_params
  end

  def building_params
    params.require(:building).permit!
  end
end
