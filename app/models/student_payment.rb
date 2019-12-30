# frozen_string_literal: true

class StudentPayment < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :student
  belongs_to :paymethod

  belongs_to :receiver, class_name: 'Staff'

  validates :pay_date, timeliness: { type: :date, on_or_before: :today }, presence: true
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :gen, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :settlement_price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :check_gen_or_yen

  after_initialize :default_values, if: :new_record?
  before_validation :default_values
  after_save { student.rebalance! }
  after_destroy { student.rebalance! }

  private

  def check_gen_or_yen
    return if gen.blank?

    errors.add(:gen, "は#{Paymethod.find(Paymethod::IN_CHINA).name}の場合のみ入力可能です") if gen&.positive? && paymethod_id != Paymethod::IN_CHINA
    errors.add(:gen, "は#{StudentPayment.human_attribute_name(:price)}がある場合には入力できません。どちらか一方のみとしてください") if gen&.positive? && price&.positive?
  end

  def default_values
    self.price = 0 if price.nil?
    self.gen = 0 if gen.blank?
    self.settlement_price = price if (settlement_price.blank? || settlement_price.zero?) && price.present?
    self.pay_date = Time.zone.today if pay_date.nil?
  end
end
