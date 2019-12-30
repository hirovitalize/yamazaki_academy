# frozen_string_literal: true

class StudentMentorsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_student_mentor, only: %i[show destroy]
  before_action :init_student_mentor, only: %i[new create]
  before_action :edit_student_mentor, only: %i[edit update]
  before_action -> { check_authorize(@student_mentor, controller_name) }, only: %i[new create edit update destroy]

  # GET /student_mentors
  def index
    @q = StudentMentor.all.order(id: :desc).includes(:staff, :student).ransack(params[:q])
    @student_mentors = @q.result.page(params[:page])
    respond_with(@student_mentors)
  end

  # GET /student_mentors/1
  def show
    respond_with(@student_mentor)
  end

  # GET /student_mentors/new
  def new
    @student_mentor.staff_id = params[:current_user].to_i
    respond_with(@student_mentor)
  end

  # GET /student_mentors/1/edit
  def edit
    respond_with(@student_mentor)
  end

  # POST /student_mentors
  def create
    @student_mentor.save
    respond_with(@student_mentor)
  end

  # PATCH/PUT /student_mentors/1
  def update
    @student_mentor.save
    respond_with(@student_mentor)
  end

  # DELETE /student_mentors/1
  def destroy
    @student_mentor.destroy
    respond_with(@student_mentor, action: :show)
  end

  private

  def set_student_mentor
    @student_mentor = StudentMentor.with_deleted.find(params[:id])
  end

  def init_student_mentor
    attributes = params[:student_mentor].blank? ? {} : student_mentor_params
    @student_mentor = StudentMentor.new attributes
  end

  def edit_student_mentor
    set_student_mentor
    return if params[:student_mentor].blank?

    @student_mentor.attributes = student_mentor_params
  end

  def student_mentor_params
    params.require(:student_mentor).permit!
  end
end
