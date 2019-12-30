# frozen_string_literal: true

class DateTimeInput < SimpleForm::Inputs::DateTimeInput
  enable :placeholder, :min_max

  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    template.content_tag(:div, class: "input-group #{input_type}") do
      template.concat span_table
      template.concat @builder.text_field(attribute_name, merged_input_options)
    end
  end

  def input_html_options
    super.merge('data-widget': "#{input_type}picker", autocomplete: 'off')
  end

  def span_table
    template.content_tag(:span, class: 'input-group-prepend') do
      template.content_tag(:span, '', class: 'input-group-text') do
        attach_icon_class
      end
    end
  end

  private

  def attach_icon_class
    if input_type == :date
      template.concat content_tag(:span, '', class: 'fa fa-calendar')
    else # :datetime, :time
      template.concat content_tag(:span, '', class: 'fa fa-clock-o')
    end
  end
end
