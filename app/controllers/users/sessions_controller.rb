# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    layout 'auth'

    # before_action :configure_sign_in_params, only: [:create]
    after_action :regenerate_token, only: [:create]
    before_action :expire_token, only: [:destroy]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    # def create
    #   super
    # end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    protected

    def regenerate_token
      return if current_user.blank?

      current_user.regenerate_auth_token
      current_user.save
    end

    def expire_token
      current_user.update(auth_token: nil) if current_user.present?
    end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end

    def after_sign_in_path_for(_resource)
      root_path
    end
  end
end
