# frozen_string_literal: true

class LectureDecorator < Draper::Decorator
  delegate_all

  def view_tags
    return [] if cached_tag_list.blank?

    object.tags.map do |tag|
      h.content_tag(:span, class: "badge badge-#{tag.severity.presence || 'secondary'}") do
        tag.name
      end
    end
  end

  def view_tags_approved
    tags = []

    if object.confirmed_approved?
      clazz = 'badge badge-success'
      text = "#{model.confirmed_at} by #{model.confirmer&.to_label}"
    elsif object.confirmed_unapproved?
      clazz = 'badge badge-danger'
      text = "#{model.confirmed_at} by #{model.confirmer&.to_label}"
    else
      clazz = 'badge badge-warning'
      text = ''
    end
    tags << h.tooltip(text) do
      h.content_tag(:span, object.confirmed_i18n, class: clazz)
    end
    tags
  end

  def view_time_range
    "#{object.start_time} - #{object.finish_time&.to_s(:time)}"
  end
end
