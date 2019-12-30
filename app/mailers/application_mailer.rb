# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'admin@coach-ac.info'
  layout 'mailer'
end
