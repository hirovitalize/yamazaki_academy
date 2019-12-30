# frozen_string_literal: true

class AutocompleteInput < SimpleForm::Inputs::CollectionSelectInput
  def input_html_classes
    super.push('form-control').push('select2-autocomplete')
  end
end
