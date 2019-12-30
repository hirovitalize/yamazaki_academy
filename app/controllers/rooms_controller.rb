# frozen_string_literal: true

class RoomsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_room, only: %i[show destroy]
  before_action :init_room, only: %i[new create]
  before_action :edit_room, only: %i[edit update]
  before_action -> { check_authorize(@room, controller_name) }, only: %i[new create edit update destroy]

  # GET /rooms
  def index
    if params[:reserve_by_room]
      redirect_to calendar_reserves_path(r: params.require(:q).permit! || {})
      return
    end

    @q = Room.all.includes(:room_room_groups, :room_groups, :room_equipments, :equipments, :building).order(id: :desc).ransack(params[:q])
    @rooms = @q.result.page(params[:page])
    respond_with(@rooms)
  end

  # GET /rooms/1
  def show
    respond_with(@room)
  end

  # GET /rooms/new
  def new
    respond_with(@room)
  end

  # GET /rooms/1/edit
  def edit
    respond_with(@room)
  end

  # POST /rooms
  def create
    @room.save
    respond_with(@room)
  end

  # PATCH/PUT /rooms/1
  def update
    @room.save
    respond_with(@room)
  end

  # DELETE /rooms/1
  def destroy
    @room.destroy
    respond_with(@room, action: :show)
  end

  private

  def set_room
    @room = Room.with_deleted.find(params[:id])
  end

  def init_room
    attributes = params[:room].blank? ? {} : room_params
    @room = Room.new attributes
  end

  def edit_room
    set_room
    return if params[:room].blank?

    @room.attributes = room_params
  end

  def room_params
    params.require(:room).permit!
  end
end
