# frozen_string_literal: true

class VipsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_vip, only: %i[show destroy]
  before_action :init_vip, only: %i[new create]
  before_action :edit_vip, only: %i[edit update]
  before_action -> { check_authorize(@vip, controller_name) }, only: %i[new create edit update destroy]

  # GET /vips
  def index
    @q = Vip.all.order(id: :desc).includes(:course_category).ransack(params[:q])
    @vips = @q.result.page(params[:page])
    respond_with(@vips)
  end

  # GET /vips/1
  def show
    respond_with(@vip)
  end

  # GET /vips/new
  def new
    respond_with(@vip)
  end

  # GET /vips/1/edit
  def edit
    respond_with(@vip)
  end

  # POST /vips
  def create
    @vip.save
    respond_with(@vip)
  end

  # PATCH/PUT /vips/1
  def update
    @vip.save
    respond_with(@vip)
  end

  # DELETE /vips/1
  def destroy
    @vip.destroy
    respond_with(@vip, action: :show)
  end

  private

  def set_vip
    @vip = Vip.with_deleted.find(params[:id])
  end

  def init_vip
    attributes = params[:vip].blank? ? {} : vip_params
    @vip = Vip.new attributes
  end

  def edit_vip
    set_vip
    return if params[:vip].blank?

    @vip.attributes = vip_params
  end

  def vip_params
    params.require(:vip).permit!
  end
end
