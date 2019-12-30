# frozen_string_literal: true

class StudentBilling < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :student
  has_many :student_billing_details, dependent: :destroy

  validates :student_billing_details, length: { in: (1..100) }

  validates :total, numericality: { only_integer: true,
                                    equal_to: ->(me) { me.student_billing_details.reject(&:marked_for_destruction?).sum(&:final_price) } }

  validates_associated :student

  after_initialize :default_values, if: :new_record?
  after_save :register_course_category_in_student
  after_save { student.rebalance! }
  after_destroy { student.rebalance! }

  accepts_nested_attributes_for :student_billing_details,
                                reject_if: :all_blank, allow_destroy: true

  private

  def register_course_category_in_student
    categories = student_billing_details.map(&:item).compact.select { |item| item.respond_to?(:course_category) }.map(&:course_category).uniq

    student.course_categories << categories - student.course_categories
  end

  def default_values
    self.total = 0 if total.nil?
  end
end
