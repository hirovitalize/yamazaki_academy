# frozen_string_literal: true

class StudentBillingsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_student_billing, only: %i[show destroy]
  before_action :init_student_billing, only: %i[new create]
  before_action :edit_student_billing, only: %i[edit update]
  before_action -> { check_authorize(@student_billing, controller_name) }, only: %i[new create edit update destroy]

  # GET /student_billings
  def index
    @q = StudentBilling.all.order(id: :desc).includes(:student).ransack(params[:q])
    @student_billings = @q.result.page(params[:page])
    respond_with(@student_billings)
  end

  # GET /student_billings/1
  def show
    respond_with(@student_billing)
  end

  # GET /student_billings/new
  def new
    respond_with(@student_billing)
  end

  # GET /student_billings/1/edit
  def edit
    respond_with(@student_billing)
  end

  # POST /student_billings
  def create
    @student_billing.save
    respond_with(@student_billing)
  end

  # PATCH/PUT /student_billings/1
  def update
    @student_billing.save
    respond_with(@student_billing)
  end

  # DELETE /student_billings/1
  def destroy
    @student_billing.destroy
    respond_with(@student_billing, action: :show)
  end

  private

  def set_student_billing
    @student_billing = StudentBilling.with_deleted.find(params[:id])
  end

  def init_student_billing
    attributes = params[:student_billing].blank? ? {} : student_billing_params
    @student_billing = StudentBilling.new attributes
  end

  def edit_student_billing
    set_student_billing
    return if params[:student_billing].blank?

    @student_billing.attributes = student_billing_params
  end

  def student_billing_params
    params.require(:student_billing).permit!
  end
end
