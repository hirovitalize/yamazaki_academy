# frozen_string_literal: true

class CoursesController < ApplicationController
  responders :flash, :http_cache
  before_action :set_course, only: %i[show destroy]
  before_action :init_course, only: %i[new create]
  before_action :edit_course, only: %i[edit update]
  before_action -> { check_authorize(@course, controller_name) }, only: %i[new create edit update destroy]

  # GET /courses
  def index
    @q = Course.all.order(id: :desc).includes(:course_category).ransack(params[:q])
    @courses = @q.result.page(params[:page])
    respond_with(@courses)
  end

  # GET /courses/1
  def show
    respond_with(@course)
  end

  # GET /courses/new
  def new
    respond_with(@course)
  end

  # GET /courses/1/edit
  def edit
    respond_with(@course)
  end

  # POST /courses
  def create
    @course.save
    respond_with(@course)
  end

  # PATCH/PUT /courses/1
  def update
    @course.save
    respond_with(@course)
  end

  # DELETE /courses/1
  def destroy
    @course.destroy
    respond_with(@course, action: :show)
  end

  private

  def set_course
    @course = Course.with_deleted.find(params[:id])
  end

  def init_course
    attributes = params[:course].blank? ? {} : course_params
    @course = Course.new attributes
  end

  def edit_course
    set_course
    return if params[:course].blank?

    @course.attributes = course_params
  end

  def course_params
    params.require(:course).permit!
  end
end
