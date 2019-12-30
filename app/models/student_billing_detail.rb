# frozen_string_literal: true

class StudentBillingDetail < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :student_billing
  belongs_to :item, polymorphic: true, optional: true
  has_one :student_billing_detail_discount, dependent: :destroy

  alias discount student_billing_detail_discount

  validates :unit_price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true
  validates :number, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :price, numericality: { only_integer: true,
                                    greater_than_or_equal_to: 0,
                                    equal_to: ->(me) { (me.number.to_d * me.unit_price.to_d).to_i } }
  validates :final_price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :item_type, presence: true, if: ->(me) { me.item_id.present? }

  accepts_nested_attributes_for :student_billing_detail_discount,
                                reject_if: :all_blank, allow_destroy: true

  after_initialize :default_values, if: :new_record?
  before_validation :normalize_prices
  around_save :sync_vip_points
  after_destroy :sync_destruction_vip_points

  def self.item_of(clazz)
    all.where(item_type: clazz.blank? ? nil : clazz.to_s.singularize.classify)
  end

  def name
    item&.to_label.presence || memo
  end

  def final_price
    [price.to_i - discount&.price.to_i, 0].max
  end

  private

  def normalize_prices
    return self.price = (unit_price.to_d * number.to_d).to_i if price.nil? || price.zero?
    return self.unit_price = (price.to_d / number.to_d).to_i if unit_price.nil? || unit_price.zero?

    self.number = (price.to_d / unit_price.to_d).to_f if number.nil? || number.zero?
  end

  def default_values
    self.price = 0 if price.nil?
    self.unit_price = 0 if unit_price.nil?
    self.number = 1.0 if number.nil?
  end

  def sync_vip_points
    diff = number_diff
    yield
    update_point_for_vip!(diff)
  end

  def sync_destruction_vip_points
    update_point_for_vip!(-1.to_d * number_was)
  end

  def number_diff
    new_number = deleted? || marked_for_destruction? || student_billing.deleted? || student_billing.marked_for_destruction? ? 0 : number
    new_number.to_d - (new_record? ? 0 : number_was).to_d
  end

  def update_point_for_vip!(diff_hour)
    return unless item_type == 'Vip'
    return if diff_hour.zero?

    point = student_billing.student&.student_point || student_billing.student&.build_student_point
    point.total = (point.total || 0) + (60.to_d * diff_hour.to_d).to_i
    point.save!
  end
end
