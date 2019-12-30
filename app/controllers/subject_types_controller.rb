# frozen_string_literal: true

class SubjectTypesController < ApplicationController
  responders :flash, :http_cache
  before_action :set_subject_type, only: %i[show destroy]
  before_action :init_subject_type, only: %i[new create]
  before_action :edit_subject_type, only: %i[edit update]
  before_action -> { check_authorize(@subject_type, controller_name) }, only: %i[new create edit update destroy]

  # GET /subject_types
  def index
    @q = SubjectType.all.includes(:subject_type_room_groups, :available_room_groups).order(id: :desc).ransack(params[:q])
    @subject_types = @q.result.page(params[:page])
    respond_with(@subject_types)
  end

  # GET /subject_types/1
  def show
    respond_with(@subject_type)
  end

  # GET /subject_types/new
  def new
    respond_with(@subject_type)
  end

  # GET /subject_types/1/edit
  def edit
    respond_with(@subject_type)
  end

  # POST /subject_types
  def create
    @subject_type.save
    respond_with(@subject_type)
  end

  # PATCH/PUT /subject_types/1
  def update
    @subject_type.save
    respond_with(@subject_type)
  end

  # DELETE /subject_types/1
  def destroy
    @subject_type.destroy
    respond_with(@subject_type, action: :show)
  end

  private

  def set_subject_type
    @subject_type = SubjectType.with_deleted.find(params[:id])
  end

  def init_subject_type
    attributes = params[:subject_type].blank? ? {} : subject_type_params
    @subject_type = SubjectType.new attributes
  end

  def edit_subject_type
    set_subject_type
    return if params[:subject_type].blank?

    @subject_type.attributes = subject_type_params
  end

  def subject_type_params
    params.require(:subject_type).permit!
  end
end
