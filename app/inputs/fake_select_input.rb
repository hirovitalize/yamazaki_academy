# frozen_string_literal: true

# https://github.com/plataformatec/simple_form/wiki/Create-a-fake-input-that-does-NOT-read-attributes
class FakeSelectInput < SimpleForm::Inputs::CollectionSelectInput
  def input(wrapper_options = nil)
    label_method, value_method = detect_collection_methods

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
                           .merge(input_options.slice(:multiple, :include_blank, :disabled, :prompt))

    template.select_tag(
      attribute_name,
      template.options_from_collection_for_select(collection,
                                                  value_method,
                                                  label_method,
                                                  selected: input_options[:selected],
                                                  disabled: input_options[:disabled]),
      merged_input_options
    )
  end

  def input_html_options
    super.merge('data-widget': 'select2')
  end
end
