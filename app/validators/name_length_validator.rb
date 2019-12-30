# frozen_string_literal: true

class NameLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    max_length = 100

    return if value.blank?
    return if value.length <= max_length

    record.errors.add(attribute, I18n.t('errors.messages.too_long', count: max_length))
  end
end
