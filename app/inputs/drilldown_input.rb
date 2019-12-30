# frozen_string_literal: true

class DrilldownInput < SimpleForm::Inputs::CollectionSelectInput
  def input_html_classes
    super.push('form-control').push('select2-drilldown')
  end
end
