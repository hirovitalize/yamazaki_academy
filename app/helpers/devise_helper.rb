# frozen_string_literal: true

module DeviseHelper
  def devise_error_messages!
    return '' unless devise_error_messages?

    messages = resource.errors.full_messages.map { |msg| attach_icon(msg) }.join
    html = <<-HTML
    <div class="alert alert-danger">
      #{messages}
    </div>
    HTML

    html.html_safe
  end

  def devise_error_messages?
    !resource.errors.empty?
  end

  private

  def attach_icon(msg)
    content_tag(:p, class: 'm-0') do
      concat content_tag(:i, '', class: 'fa fa-ban mr-1')
      concat content_tag(:span, msg)
    end
  end
end
