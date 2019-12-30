# frozen_string_literal: true

class AddonInput < SimpleForm::Inputs::Base
  # 入力欄をinput-groupにし、その前後に、span-addonを追加します
  # 例:
  # f.input :price, as: :addon, prepend: fa_icon(:fire), append: '円'
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    template.content_tag(:div, class: "input-group #{input_type}") do
      template.concat prepend(input_options.delete(:prepend)) if input_options.key? :prepend
      template.concat @builder.input_field(attribute_name, merged_input_options)
      template.concat append(input_options.delete(:append)) if input_options.key? :append
    end
  end

  private

  def prepend(content)
    template.content_tag(:div, class: 'input-group-prepend') do
      template.content_tag(:div, class: 'input-group-text') do
        content
      end
    end
  end

  def append(content)
    template.content_tag(:div, class: 'input-group-append') do
      template.content_tag(:div, class: 'input-group-text') do
        content
      end
    end
  end
end
