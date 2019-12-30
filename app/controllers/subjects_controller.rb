# frozen_string_literal: true

class SubjectsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_subject, only: %i[show destroy]
  before_action :init_subject, only: %i[new create]
  before_action :edit_subject, only: %i[edit update]
  before_action -> { check_authorize(@subject, controller_name) }, only: %i[new create edit update destroy]

  # GET /subjects
  def index
    @q = Subject.all.order(id: :desc).includes(:subject_category, :klass_template_subjects, :klass_templates, :staff_subjects, :staffs).ransack(params[:q])
    @subjects = @q.result.page(params[:page])
    respond_with(@subjects)
  end

  # GET /subjects/1
  def show
    respond_with(@subject)
  end

  # GET /subjects/new
  def new
    respond_with(@subject)
  end

  # GET /subjects/1/edit
  def edit
    respond_with(@subject)
  end

  # POST /subjects
  def create
    @subject.save
    respond_with(@subject)
  end

  # PATCH/PUT /subjects/1
  def update
    @subject.save
    respond_with(@subject)
  end

  # DELETE /subjects/1
  def destroy
    @subject.destroy
    respond_with(@subject, action: :show)
  end

  private

  def set_subject
    @subject = Subject.with_deleted.find(params[:id])
  end

  def init_subject
    attributes = params[:subject].blank? ? {} : subject_params
    @subject = Subject.new attributes
  end

  def edit_subject
    set_subject
    return if params[:subject].blank?

    @subject.attributes = subject_params
  end

  def subject_params
    params.require(:subject).permit!
  end
end
