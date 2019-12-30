# frozen_string_literal: true

class Course < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :course_category

  has_many :course_klass_templates, dependent: :destroy
  has_many :klass_templates, through: :course_klass_templates
  has_many :student_billing_details, as: :item, dependent: :restrict_with_error

  validates :name, presence: true,
                   length: { in: (0..100) }
  validates :price, presence: true,
                    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
