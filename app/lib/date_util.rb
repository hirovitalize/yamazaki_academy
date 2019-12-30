# frozen_string_literal: true

module DateUtil
  def self.valid_date?(date)
    return false if date.blank?
    return false unless date =~ %r{\d{4}/\d{2}/\d{2}} || date =~ %r{\d{4}/\d{2}}

    date_arr = date.split('/').push('01')
    Date.valid_date?(*date_arr.take(3).map(&:to_i))
  end
end
