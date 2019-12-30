# frozen_string_literal: true

class Paymethod < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  has_many :student_payments, dependent: :restrict_with_error
  validates :name, presence: true,
                   length: { in: (0..100) }

  IN_CHINA = 9
  IN_JAPANESE_SCHOOL = 10
end
