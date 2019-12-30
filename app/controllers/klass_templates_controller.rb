# frozen_string_literal: true

class KlassTemplatesController < ApplicationController
  responders :flash, :http_cache
  before_action :set_klass_template, only: %i[show destroy]
  before_action :init_klass_template, only: %i[new create]
  before_action :edit_klass_template, only: %i[edit update]

  before_action -> { check_authorize(@klass_template, controller_name) }, only: %i[new create edit update destroy]

  # GET /klass_templates
  def index
    @q = KlassTemplate.all.order(id: :desc).includes(:course_category, :klass_template_subjects, :subjects, :klasses).ransack(params[:q])
    @klass_templates = @q.result.page(params[:page])
    respond_with(@klass_templates)
  end

  # GET /klass_templates/1
  def show
    respond_with(@klass_template)
  end

  # GET /klass_templates/new
  def new
    respond_with(@klass_template)
  end

  # GET /klass_templates/1/edit
  def edit
    respond_with(@klass_template)
  end

  # POST /klass_templates
  def create
    @klass_template.save
    respond_with(@klass_template)
  end

  # PATCH/PUT /klass_templates/1
  def update
    @klass_template.save
    respond_with(@klass_template)
  end

  # DELETE /klass_templates/1
  def destroy
    @klass_template.destroy
    respond_with(@klass_template, action: :show)
  end

  private

  def set_klass_template
    @klass_template = KlassTemplate.with_deleted.find(params[:id])
  end

  def init_klass_template
    attributes = params[:klass_template].blank? ? {} : klass_template_params
    @klass_template = KlassTemplate.new attributes
  end

  def edit_klass_template
    set_klass_template
    return if params[:klass_template].blank?

    @klass_template.attributes = klass_template_params
  end

  def klass_template_params
    params.require(:klass_template).permit!
  end
end
