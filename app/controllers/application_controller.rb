# frozen_string_literal: true

require 'application_responder'

class ApplicationController < ActionController::Base
  include Pundit
  self.responder = ApplicationResponder
  respond_to :html, :json, :xml
  protect_from_forgery with: :exception, prepend: true

  before_action :basic_auth
  before_action :authenticate_user!
  before_action :set_mailer_host if Rails.env.development?
  before_action :set_csrf, :set_auth_token
  before_action :set_paper_trail_whodunnit
  before_action :set_raven_context
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  def set_locale
    I18n.locale = locale
  end

  def locale
    @locale ||= params[:locale] || I18n.default_locale
  end

  def default_url_options(options = {})
    options.merge(locale: locale)
  end

  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  def set_csrf
    gon.csrf = form_authenticity_token
  end

  def set_auth_token
    gon.auth_token = current_user.auth_token if current_user.present?
  end

  def info_for_paper_trail
    { comment: params.fetch(:version_comment, '') }
  end

  private

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  protected

  def basic_auth
    return true unless ENV['BASIC_AUTH_USER'].present? && ENV['BASIC_AUTH_PASSWORD'].present?

    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['BASIC_AUTH_USER'] && password == ENV['BASIC_AUTH_PASSWORD']
    end
  end

  def check_authorize(record, name)
    authorize(record.presence || name.classify.constantize)
  rescue NoMethodError
    true
  rescue Pundit::NotDefinedError
    true
  end

  def configure_permitted_parameters
    added_attrs = %i[name email password password_confirmation encrypted_password]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
