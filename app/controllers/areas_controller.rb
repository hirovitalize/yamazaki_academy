# frozen_string_literal: true

class AreasController < ApplicationController
  responders :flash, :http_cache
  before_action :set_area, only: %i[show destroy]
  before_action :init_area, only: %i[new create]
  before_action :edit_area, only: %i[edit update]
  before_action -> { check_authorize(@area, controller_name) }, only: %i[new create edit update destroy]

  # GET /areas
  def index
    @q = Area.all.order(id: :desc).includes(:province).ransack(params[:q])
    @areas = @q.result.page(params[:page])
    respond_with(@areas)
  end

  # GET /areas/1
  def show
    respond_with(@area)
  end

  # GET /areas/new
  def new
    respond_with(@area)
  end

  # GET /areas/1/edit
  def edit
    respond_with(@area)
  end

  # POST /areas
  def create
    @area.save
    respond_with(@area)
  end

  # PATCH/PUT /areas/1
  def update
    @area.save
    respond_with(@area)
  end

  # DELETE /areas/1
  def destroy
    @area.destroy
    respond_with(@area, action: :show)
  end

  private

  def set_area
    @area = Area.with_deleted.find(params[:id])
  end

  def init_area
    attributes = params[:area].blank? ? {} : area_params
    @area = Area.new attributes
  end

  def edit_area
    set_area
    return if params[:area].blank?

    @area.attributes = area_params
  end

  def area_params
    params.require(:area).permit!
  end
end
