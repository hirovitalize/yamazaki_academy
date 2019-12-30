# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  rescue_from Exception do |e|
    Raven.extra_context(clazz: self.class, job_id: job_id)
    Raven.capture_exception(e)
    raise e
  end
end
