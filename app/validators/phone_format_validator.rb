# frozen_string_literal: true

class PhoneFormatValidator < ActiveModel::EachValidator
  CODE_REGEX = /^\d{1,13}$/.freeze

  def validate_each(record, attribute, value)
    return if value.blank?
    return if value =~ CODE_REGEX

    record.errors.add(attribute, 'を正しい形式で入力してください')
  end
end
