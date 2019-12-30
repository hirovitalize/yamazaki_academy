# frozen_string_literal: true

class Book < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  has_many :student_billing_details, as: :item, dependent: :restrict_with_error

  validates :name, presence: true,
                   length: { in: (0..100) }
  validates :price, presence: true,
                    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :isbn, allow_blank: true,
                   uniqueness: { scope: :deleted_at },
                   format: { with: /^\d+[-]\d+[-]\d+[-]\d+[-]\d+$/, multiline: true }
end
