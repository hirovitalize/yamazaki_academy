# frozen_string_literal: true

class VipPrice < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  validates :name, presence: true, length: { in: (0..100) }
  validates :hours_min, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :hours_max, numericality: { only_integer: true, greater_than: :hours_min }
  validates :unit_price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.unit_price_by_hours(hours)
    return nil if hours.blank?

    unit(hours).first&.unit_price
  end

  # scope
  def self.unit(hours)
    all.where('hours_min <= ? and hours_max >= ?', hours, hours)
  end
end
