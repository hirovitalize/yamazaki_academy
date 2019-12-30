# frozen_string_literal: true

class KatakanaFormatValidator < ActiveModel::EachValidator
  CODE_REGEX = /^[ァ-ンー]*$/.freeze

  def validate_each(record, attribute, value)
    return if value.blank?
    return if value.match(CODE_REGEX).present?

    record.errors.add(attribute, 'を正しい形式で入力してください')
  end
end
