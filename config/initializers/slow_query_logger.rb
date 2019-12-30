# @see http://pdabrowski.com/blog/ruby-on-rails/slow-query-log/
class SlowQueryLogger
  MAX_DURATION = 3.0

  def self.initialize!
    ActiveSupport::Notifications.subscribe('sql.active_record') do |name, start, finish, id, payload|
      duration = finish.to_f - start.to_f

      if duration >= MAX_DURATION
        message = "slow query detected: #{payload[:sql]}, duration: #{duration}"
        Rails.logger.warn message
        Raven.capture_message message
      end
    end
  end
end

SlowQueryLogger.initialize!
