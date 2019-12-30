# frozen_string_literal: true

module ActionView
  module I18nHelper
    def t_field(klass, field)
      klass = klass.to_s if klass.is_a? Symbol
      klass = klass.camelize.constantize if klass.is_a? String
      klass = klass.class if klass.is_a? ActiveRecord::Base
      klass.human_attribute_name(field)
    end

    def t_model(klass)
      klass = klass.to_s if klass.is_a? Symbol
      klass = klass.camelize.constantize if klass.is_a? String
      klass = klass.class if klass.is_a? ActiveRecord::Base
      klass.model_name.human
    end

    def t_icon(klass, append = nil, options = {})
      fa_icon t_field(klass, :faicon) + (append.present? ? " #{append}" : ''), options
    end

    # アイコン + 文字列
    # おもにタイトルなどで使う
    def t_iconed_model(klass, type = nil)
      content = t_model(klass)
      content = t("helpers.title.#{type}", model: content, name: name(klass)) if type.present?

      t_icon(klass, 'fw') + content
    end

    private

    def name(object)
      field = SimpleForm.collection_label_methods.find { |m| object.respond_to?(m) }
      return nil if field.blank?

      object.send(field)
    end
  end
end
