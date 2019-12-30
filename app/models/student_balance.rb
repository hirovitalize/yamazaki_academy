# frozen_string_literal: true

class StudentBalance < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :student

  %i[billings_total payments_total].each do |field|
    validates field, numericality: { only_integer: true,
                                     greater_than_or_equal_to: 0 }
  end
  validates :price, numericality: { only_integer: true }

  after_initialize :default_values, if: :new_record?
  before_validation :calc_price

  def name
    "#{price.negative? ? '過払' : '残'} #{price}円"
  end

  def completed?
    price <= 0
  end

  private

  def calc_price
    self.price = billings_total - payments_total
  end

  def default_values
    self.billings_total = 0 if billings_total.nil?
    self.payments_total = 0 if payments_total.nil?
    calc_price
  end
end
