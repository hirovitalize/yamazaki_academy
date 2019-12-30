# frozen_string_literal: true

class RolesController < ApplicationController
  responders :flash, :http_cache
  before_action :set_role, only: %i[show destroy]
  before_action :init_role, only: %i[new create]
  before_action :edit_role, only: %i[edit update]
  before_action -> { check_authorize(@role, controller_name) }, only: %i[new create edit update destroy index show]

  # GET /roles
  def index
    @q = Role.all.order(id: :desc).includes(:staff_roles, :staffs).ransack(params[:q])
    @roles = @q.result.page(params[:page])
    respond_with(@roles)
  end

  # GET /roles/1
  def show
    respond_with(@role)
  end

  # GET /roles/new
  def new
    respond_with(@role)
  end

  # GET /roles/1/edit
  def edit
    respond_with(@role)
  end

  # POST /roles
  def create
    @role.save
    respond_with(@role)
  end

  # PATCH/PUT /roles/1
  def update
    @role.save
    respond_with(@role)
  end

  # DELETE /roles/1
  def destroy
    @role.destroy
    respond_with(@role, action: :show)
  end

  private

  def set_role
    @role = Role.with_deleted.find(params[:id])
  end

  def init_role
    attributes = params[:role].blank? ? {} : role_params
    @role = Role.new attributes
  end

  def edit_role
    set_role
    return if params[:role].blank?

    @role.attributes = role_params
  end

  def role_params
    params.require(:role).permit!
  end
end
