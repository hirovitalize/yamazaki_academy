# frozen_string_literal: true

class RoomGroupsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_room_group, only: %i[show destroy]
  before_action :init_room_group, only: %i[new create]
  before_action :edit_room_group, only: %i[edit update]
  before_action -> { check_authorize(@room_group, controller_name) }, only: %i[new create edit update destroy]

  # GET /room_groups
  def index
    @q = RoomGroup.all.order(id: :desc).ransack(params[:q])
    @room_groups = @q.result.page(params[:page])
    respond_with(@room_groups)
  end

  # GET /room_groups/1
  def show
    respond_with(@room_group)
  end

  # GET /room_groups/new
  def new
    respond_with(@room_group)
  end

  # GET /room_groups/1/edit
  def edit
    respond_with(@room_group)
  end

  # POST /room_groups
  def create
    @room_group.save
    respond_with(@room_group)
  end

  # PATCH/PUT /room_groups/1
  def update
    @room_group.save
    respond_with(@room_group)
  end

  # DELETE /room_groups/1
  def destroy
    @room_group.destroy
    respond_with(@room_group, action: :show)
  end

  private

  def set_room_group
    @room_group = RoomGroup.with_deleted.find(params[:id])
  end

  def init_room_group
    attributes = params[:room_group].blank? ? {} : room_group_params
    @room_group = RoomGroup.new attributes
  end

  def edit_room_group
    set_room_group
    return if params[:room_group].blank?

    @room_group.attributes = room_group_params
  end

  def room_group_params
    params.require(:room_group).permit!
  end
end
