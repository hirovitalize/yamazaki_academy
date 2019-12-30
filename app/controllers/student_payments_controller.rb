# frozen_string_literal: true

class StudentPaymentsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_student_payment, only: %i[show destroy]
  before_action :init_student_payment, only: %i[new create]
  before_action :edit_student_payment, only: %i[edit update]
  before_action -> { check_authorize(@student_payment, controller_name) }, only: %i[new create edit update destroy]

  # GET /student_payments
  def index
    @q = StudentPayment.all.order(id: :desc).includes(:student, :paymethod, :receiver).ransack(params[:q])
    @student_payments = @q.result.page(params[:page])
    respond_with(@student_payments)
  end

  # GET /student_payments/1
  def show
    respond_with(@student_payment)
  end

  # GET /student_payments/new
  def new
    respond_with(@student_payment)
  end

  # GET /student_payments/1/edit
  def edit
    respond_with(@student_payment)
  end

  # POST /student_payments
  def create
    @student_payment.save
    respond_with(@student_payment)
  end

  # PATCH/PUT /student_payments/1
  def update
    @student_payment.save
    respond_with(@student_payment)
  end

  # DELETE /student_payments/1
  def destroy
    @student_payment.destroy
    respond_with(@student_payment, action: :show)
  end

  private

  def set_student_payment
    @student_payment = StudentPayment.with_deleted.find(params[:id])
  end

  def init_student_payment
    attributes = params[:student_payment].blank? ? {} : student_payment_params
    @student_payment = StudentPayment.new attributes
  end

  def edit_student_payment
    set_student_payment
    return if params[:student_payment].blank?

    @student_payment.attributes = student_payment_params
  end

  def student_payment_params
    params.require(:student_payment).permit!
  end
end
