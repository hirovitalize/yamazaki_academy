# frozen_string_literal: true

class StudentCommissionsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_student_commission, only: %i[show destroy]
  before_action :init_student_commission, only: %i[new create]
  before_action :edit_student_commission, only: %i[edit update]
  before_action -> { check_authorize(@student_commission, controller_name) }, only: %i[new create edit update destroy]

  # GET /student_commissions
  def index
    @q = StudentCommission.all.order(id: :desc).includes(:student, :inflow_source, :cache_back_type).ransack(params[:q])
    @student_commissions = @q.result.page(params[:page])
    respond_with(@student_commissions)
  end

  # GET /student_commissions/1
  def show
    respond_with(@student_commission)
  end

  # GET /student_commissions/new
  def new
    respond_with(@student_commission)
  end

  # GET /student_commissions/1/edit
  def edit
    respond_with(@student_commission)
  end

  # POST /student_commissions
  def create
    @student_commission.save
    respond_with(@student_commission)
  end

  # PATCH/PUT /student_commissions/1
  def update
    @student_commission.save
    respond_with(@student_commission)
  end

  # DELETE /student_commissions/1
  def destroy
    @student_commission.destroy
    respond_with(@student_commission, action: :show)
  end

  private

  def set_student_commission
    @student_commission = StudentCommission.with_deleted.find(params[:id])
  end

  def init_student_commission
    attributes = params[:student_commission].blank? ? {} : student_commission_params
    @student_commission = StudentCommission.new attributes
  end

  def edit_student_commission
    set_student_commission
    return if params[:student_commission].blank?

    @student_commission.attributes = student_commission_params
  end

  def student_commission_params
    params.require(:student_commission).permit!
  end
end
