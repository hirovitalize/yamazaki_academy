# frozen_string_literal: true

class StudentPointsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_student_point, only: %i[show destroy]
  before_action :init_student_point, only: %i[new create]
  before_action :edit_student_point, only: %i[edit update]
  before_action -> { check_authorize(@student_point, controller_name) }, only: %i[new create edit update destroy index show]

  # GET /student_points
  def index
    @q = StudentPoint.all.includes(:student).order(id: :desc).ransack(params[:q])
    @student_points = @q.result.page(params[:page])
    respond_with(@student_points)
  end

  # GET /student_points/1
  def show
    respond_with(@student_point)
  end

  # GET /student_points/new
  def new
    respond_with(@student_point)
  end

  # GET /student_points/1/edit
  def edit
    respond_with(@student_point)
  end

  # POST /student_points
  def create
    @student_point.save
    respond_with(@student_point)
  end

  # PATCH/PUT /student_points/1
  def update
    @student_point.save
    respond_with(@student_point)
  end

  # DELETE /student_points/1
  def destroy
    @student_point.destroy
    respond_with(@student_point, action: :show)
  end

  private

  def set_student_point
    @student_point = StudentPoint.with_deleted.find(params[:id])
  end

  def init_student_point
    attributes = params[:student_point].blank? ? {} : student_point_params
    @student_point = StudentPoint.new attributes
  end

  def edit_student_point
    set_student_point
    return if params[:student_point].blank?

    @student_point.attributes = student_point_params
  end

  def student_point_params
    params.require(:student_point).permit!
  end
end
