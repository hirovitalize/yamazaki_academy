# frozen_string_literal: true

class LectureStudentsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_lecture_student, only: %i[show]

  # GET /lecture_students
  def index
    @q = LectureStudent.all.includes(:lecture, :student).order(id: :desc).ransack(params[:q])
    @lecture_students = @q.result.page(params[:page])
    respond_with(@lecture_students)
  end

  # GET /lecture_students/1
  def show
    respond_with(@lecture_student)
  end

  private

  def set_lecture_student
    @lecture_student = LectureStudent.with_deleted.find(params[:id])
  end

  def init_lecture_student
    attributes = params[:lecture_student].blank? ? {} : lecture_student_params
    @lecture_student = LectureStudent.new attributes
  end

  def edit_lecture_student
    set_lecture_student
    return if params[:lecture_student].blank?

    @lecture_student.attributes = lecture_student_params
  end

  def lecture_student_params
    params.require(:lecture_student).permit!
  end
end
