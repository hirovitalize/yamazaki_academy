# frozen_string_literal: true

class CustomContentInput < SimpleForm::Inputs::Base
  disable :hint
  # https://github.com/plataformatec/simple_form/wiki/Create-an-%22input%22-just-for-displaying-custom-content-(e.g.-a-link)
  # You have to pass the content by capturing it as a block into a var,
  # then pass it to the +content+ option
  def input(wrapper_options = nil)
    # https://github.com/plataformatec/simple_form/blob/master/lib/simple_form/components/labels.rb#28
    template.content_tag(:div, input_options.merge(input_html_options).merge(wrapper_options).delete(:content))
  end

  def additional_classes
    @additional_classes ||= [input_type].compact
    # original is `[input_type, required_class, readonly_class, disabled_class].compact`
  end
end
