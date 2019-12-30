# frozen_string_literal: true

class EquipmentsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_equipment, only: %i[show destroy]
  before_action :init_equipment, only: %i[new create]
  before_action :edit_equipment, only: %i[edit update]
  before_action -> { check_authorize(@equipment, controller_name) }, only: %i[new create edit update destroy]

  # GET /equipments
  def index
    @q = Equipment.all.order(id: :desc).ransack(params[:q])
    @equipments = @q.result.page(params[:page])
    respond_with(@equipments)
  end

  # GET /equipments/1
  def show
    respond_with(@equipment)
  end

  # GET /equipments/new
  def new
    respond_with(@equipment)
  end

  # GET /equipments/1/edit
  def edit
    respond_with(@equipment)
  end

  # POST /equipments
  def create
    @equipment.save
    respond_with(@equipment)
  end

  # PATCH/PUT /equipments/1
  def update
    @equipment.save
    respond_with(@equipment)
  end

  # DELETE /equipments/1
  def destroy
    @equipment.destroy
    respond_with(@equipment, action: :show)
  end

  private

  def set_equipment
    @equipment = Equipment.with_deleted.find(params[:id])
  end

  def init_equipment
    attributes = params[:equipment].blank? ? {} : equipment_params
    @equipment = Equipment.new attributes
  end

  def edit_equipment
    set_equipment
    return if params[:equipment].blank?

    @equipment.attributes = equipment_params
  end

  def equipment_params
    params.require(:equipment).permit!
  end
end
