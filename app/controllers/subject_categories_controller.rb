# frozen_string_literal: true

class SubjectCategoriesController < ApplicationController
  responders :flash, :http_cache
  before_action :set_subject_category, only: %i[show destroy]
  before_action :init_subject_category, only: %i[new create]
  before_action :edit_subject_category, only: %i[edit update]
  before_action -> { check_authorize(@subject_category, controller_name) }, only: %i[new create edit update destroy]

  # GET /subject_categories
  def index
    @q = SubjectCategory.all.order(id: :desc).ransack(params[:q])
    @subject_categories = @q.result.page(params[:page])
    respond_with(@subject_categories)
  end

  # GET /subject_categories/1
  def show
    respond_with(@subject_category)
  end

  # GET /subject_categories/new
  def new
    respond_with(@subject_category)
  end

  # GET /subject_categories/1/edit
  def edit
    respond_with(@subject_category)
  end

  # POST /subject_categories
  def create
    @subject_category.save
    respond_with(@subject_category)
  end

  # PATCH/PUT /subject_categories/1
  def update
    @subject_category.save
    respond_with(@subject_category)
  end

  # DELETE /subject_categories/1
  def destroy
    @subject_category.destroy
    respond_with(@subject_category, action: :show)
  end

  private

  def set_subject_category
    @subject_category = SubjectCategory.with_deleted.find(params[:id])
  end

  def init_subject_category
    attributes = params[:subject_category].blank? ? {} : subject_category_params
    @subject_category = SubjectCategory.new attributes
  end

  def edit_subject_category
    set_subject_category
    return if params[:subject_category].blank?

    @subject_category.attributes = subject_category_params
  end

  def subject_category_params
    params.require(:subject_category).permit!
  end
end
