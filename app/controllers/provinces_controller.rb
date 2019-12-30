# frozen_string_literal: true

class ProvincesController < ApplicationController
  responders :flash, :http_cache
  before_action :set_province, only: %i[show destroy]
  before_action :init_province, only: %i[new create]
  before_action :edit_province, only: %i[edit update]
  before_action -> { check_authorize(@province, controller_name) }, only: %i[new create edit update destroy]

  # GET /provinces
  def index
    @q = Province.all.order(id: :desc).ransack(params[:q])
    @provinces = @q.result.page(params[:page])
    respond_with(@provinces)
  end

  # GET /provinces/1
  def show
    respond_with(@province)
  end

  # GET /provinces/new
  def new
    respond_with(@province)
  end

  # GET /provinces/1/edit
  def edit
    respond_with(@province)
  end

  # POST /provinces
  def create
    @province.save
    respond_with(@province)
  end

  # PATCH/PUT /provinces/1
  def update
    @province.save
    respond_with(@province)
  end

  # DELETE /provinces/1
  def destroy
    @province.destroy
    respond_with(@province, action: :show)
  end

  private

  def set_province
    @province = Province.with_deleted.find(params[:id])
  end

  def init_province
    attributes = params[:province].blank? ? {} : province_params
    @province = Province.new attributes
  end

  def edit_province
    set_province
    return if params[:province].blank?

    @province.attributes = province_params
  end

  def province_params
    params.require(:province).permit!
  end
end
