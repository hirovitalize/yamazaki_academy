# frozen_string_literal: true

class KlassSubjectDecorator < Draper::Decorator
  delegate_all

  def view_lecture_numbers
    "#{lectures.count} / #{lecture_num || '無制限'}"
  end

  def view_time_range
    return "未定 (#{object.hours}h)" if object.start_time.blank?

    "#{object.start_time&.to_s(:time)} - #{object.finish_time&.to_s(:time)} (#{object.hours}h)"
  end

  def view_total_hours
    return "#{object.hours}h * 無制限" if lecture_num.blank?

    "計#{object.total_hours}h: #{object.hours}h * #{lecture_num}回"
  end
end
