# frozen_string_literal: true

class StudentBillingDetailDiscount < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :student_billing_detail
  belongs_to :discount_type, optional: true

  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :price, numericality: { equal_to: 0 }, if: -> { :discount_type.blank? }

  before_validation :default_values

  private

  def default_values
    self.price = 0 if price.nil?
  end
end
