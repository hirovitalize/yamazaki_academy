# frozen_string_literal: true

class DisplayInput < SimpleForm::Inputs::Base
  include ActionView::Context
  include ActionView::WidgetHelper

  # 例:
  # This returns just a value of the attribute.
  # f.input :price, as: :addon, prepend: fa_icon(:fire), format: ->(val){ number_to_concurency val }
  # f.input :price, as: :addon, append: '分', format: 'テスト %10s', post: true
  def input(wrapper_options = nil)
    input_html_classes
      .push('m-0')
      .push('form-control-static')
    out = template.content_tag(
      :p,
      view_string,
      input_html_options.merge(wrapper_options['input_html'] || {})
    )
    out += build_hidden(merged_input_options) if input_options.fetch(:post, false)
    out
  end

  def additional_classes
    @additional_classes ||= [input_type].compact
  end

  private

  def view_string
    val = attribute_val
    return val if val.blank?
    return val if val.is_a?(String) && val.match(/</)

    content = ''
    content += input_options[:prepend] if input_options.key? :prepend
    content += if input_options.key? :format
                 apply_format(val, input_options[:format]).to_s
               else
                 val.to_s
               end
    content += input_options[:append] if input_options.key? :append
    content
  end

  def apply_format(text, option)
    if option.is_a? Proc
      option.call(text)
    elsif option.is_a? String
      format(option, text)
    else
      text
    end
  end

  def attribute_val
    return object.send("#{attribute_name}_i18n") if enum_attributes? attribute_name

    if object.class.reflect_on_association(attribute_name)
      rel = object.send(attribute_name)
      return nil if rel.blank?
      return link_object(rel) unless rel.is_a? Enumerable

      return link_objects(rel)
    end

    value = object.send(attribute_name)
    case value
    when true then
      return ApplicationController.helpers.fa_icon 'check-square-o'
    when false then
      return ApplicationController.helpers.fa_icon 'square-o'
    else
      return value
    end
  end

  def build_hidden(merged_input_options)
    local_attribute_name = (association_key(attribute_name).presence || attribute_name)
    @builder.hidden_field(local_attribute_name, merged_input_options)
  end

  def enum_attributes?(attribute_name)
    object.class.respond_to?(:defined_enums) &&
      object.class.defined_enums.key?(attribute_name.to_s) &&
      attribute_name.to_s.pluralize != 'references'
  end

  def association_key(association)
    return nil unless object
    return nil unless object.class.respond_to?(:reflect_on_association)

    reflection = object.class.reflect_on_association(association)
    return nil if reflection.blank?

    build_association_attribute(reflection)
  end

  def build_association_attribute(reflection)
    case reflection.macro
    when :belongs_to
      (reflection.respond_to?(:options) && reflection.options[:foreign_key]) || :"#{reflection.name}_id"
    when :has_one
      nil
    else
      :"#{reflection.name.to_s.singularize}_ids"
    end
  end
end
