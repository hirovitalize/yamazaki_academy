# frozen_string_literal: true

module Users
  class Mailer < Devise::Mailer
    helper :application # gives access to all helpers defined within `application_helper`.
    include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
    default template_path: 'users/mailer'
  end
end
