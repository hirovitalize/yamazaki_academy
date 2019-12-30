# frozen_string_literal: true

# https://github.com/plataformatec/simple_form/wiki/Create-a-fake-input-that-does-NOT-read-attributes
class FakeCheckboxesInput < SimpleForm::Inputs::CollectionCheckBoxesInput
  def input(wrapper_options = nil)
    label_method, value_method = detect_collection_methods

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
                           .merge(input_options.slice(:multiple, :include_blank, :disabled, :prompt))

    template.collection_check_boxes(
      nil,
      attribute_name,
      collection,
      value_method,
      label_method,
      checked: input_options[:checked],
      html_options: merged_input_options
    )
  end
end
