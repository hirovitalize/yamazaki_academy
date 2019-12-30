# frozen_string_literal: true

module GrapeApi
  class API < Grape::API
    prefix 'api'
    version 'v1', using: :path

    helpers RequestHelper

    rescue_from Pundit::NotAuthorizedError do |e|
      error! e.message, 403 #:forbidden
    end
    rescue_from ActiveRecord::RecordNotFound do |e|
      error! e.message, 404 #:not_found
    end
    rescue_from AbstractController::ActionNotFound do |e|
      error! e.message, 404 #:not_found
    end
    rescue_from ActiveModel::UnknownAttributeError do |e|
      error! e.message, 400 #:bad_request
    end
    rescue_from ActiveRecord::RecordInvalid do |e|
      error! e.record.errors.full_messages.join(', '), 400 #:bad_request
    end
    rescue_from ActiveRecord::RecordNotDestroyed do |e|
      error! e.record.errors.full_messages.join(', '), 400 #:bad_request
    end
    rescue_from Grape::Exceptions::ValidationErrors do |e|
      error! e.message, 400 #:bad_request
    end
    rescue_from Grape::Exceptions::MethodNotAllowed do |e|
      error! e.message, 405 #:not_allowed
    end
    rescue_from :all do |e|
      Rails.logger.error(e.message.to_s + "\n" + e.backtrace.join("\n"))
      error! "#{e.message}[#{e.class}][#{e.backtrace.first}]", 500 #:internal_server_error
    end

    mount Base
  end
end
