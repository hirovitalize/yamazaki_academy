# frozen_string_literal: true

class Vip < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :course_category
  has_many :student_billing_details, as: :item, dependent: :restrict_with_error

  validates :name, presence: true,
                   length: { in: (0..100) }

  def to_label
    "[#{course_category&.name}]" + super
  end
end
