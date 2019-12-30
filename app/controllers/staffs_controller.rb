# frozen_string_literal: true

class StaffsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_staff, only: %i[show destroy]
  before_action :init_staff, only: %i[new create]
  before_action :edit_staff, only: %i[edit update]
  before_action -> { check_authorize(@staff, controller_name) }, only: %i[new create edit update destroy index show]

  # GET /staffs
  def index
    @q = Staff.all.includes(:user, :staff_roles, :roles, :staff_subjects, :subjects).order(id: :desc).ransack(params[:q])
    @staffs = @q.result.page(params[:page])
    respond_with(@staffs)
  end

  # GET /staffs/1
  def show
    respond_with(@staff)
  end

  # GET /staffs/new
  def new
    respond_with(@staff)
  end

  # GET /staffs/1/edit
  def edit
    respond_with(@staff)
  end

  # POST /staffs
  def create
    @staff.save
    respond_with(@staff)
  end

  # PATCH/PUT /staffs/1
  def update
    @staff.save
    respond_with(@staff)
  end

  # DELETE /staffs/1
  def destroy
    @staff.user.destroy
    @staff.destroy
    respond_with(@staff, action: :show)
  end

  private

  def set_staff
    @staff = Staff.with_deleted.find(params[:id])
  end

  def init_staff
    attributes = params[:staff].blank? ? {} : staff_params
    @staff = Staff.new attributes
  end

  def edit_staff
    set_staff
    return if params[:staff].blank?

    @staff.attributes = staff_params
  end

  def staff_params
    params.require(:staff).permit!
  end
end
