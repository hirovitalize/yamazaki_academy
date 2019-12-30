# frozen_string_literal: true

class UsersController < ApplicationController
  responders :flash, :http_cache
  before_action :set_user, only: %i[show destroy lock unlock]
  before_action :edit_user, only: %i[edit update]
  before_action -> { check_authorize(@user, controller_name) }, only: %i[edit update destroy index show lock unlock]

  # GET /users
  def index
    @q = User.all.includes(:staff).order(id: :desc).ransack(params[:q])
    @users = @q.result.page(params[:page])
    respond_with(@users)
  end

  # GET /users/1
  def show
    respond_with(@user)
  end

  # GET /users/1/edit
  def edit
    respond_with(@user)
  end

  # PATCH/PUT /users/1
  def update
    @user.save
    respond_with(@user)
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    respond_with(@user, action: :show)
  end

  def lock
    @user.lock_access!(send_instructions: false)
    flash[:notice] = t('controllers.users.lock.flash.notice')
    render :show
  end

  def unlock
    @user.unlock_access!
    flash[:notice] = t('controllers.users.unlock.flash.notice')
    render :show
  end

  private

  def set_user
    @user = User.with_deleted.find(params[:id])
  end

  def edit_user
    set_user
    return if params[:user].blank?

    @user.attributes = user_params
  end

  def user_params
    params.require(:user).permit!
  end
end
