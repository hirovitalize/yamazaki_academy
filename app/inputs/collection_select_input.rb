# frozen_string_literal: true

class CollectionSelectInput < SimpleForm::Inputs::CollectionSelectInput
  def input_html_options
    super.merge('data-widget': 'select2')
  end
end
