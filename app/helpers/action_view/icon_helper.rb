# frozen_string_literal: true

module ActionView
  module IconHelper
    def glyphicon(glyph)
      content_tag :span, '', class: "glyphicon glyphicon-#{glyph}", 'aria-hidden' => true
    end

    def bool_icon_tag(value, icon_true = 'check-square-o', icon_false = 'square-o', icon_null = nil)
      if value.nil?
        icon_and_hidden_value(icon_null, 'empty')
      elsif value == true
        icon_and_hidden_value(icon_true, 'true')
      elsif value == false
        icon_and_hidden_value(icon_false, 'false')
      end
    end

    private

    def icon_and_hidden_value(icon, value)
      parts = if icon.is_a?(Symbol)
                fa_icon(icon)
              elsif icon.is_a?(String)
                fa_icon(icon)
              else
                icon
              end
      content_tag(:div) do
        concat parts
        concat content_tag(:p, value, class: 'd-none')
      end
    end
  end
end
