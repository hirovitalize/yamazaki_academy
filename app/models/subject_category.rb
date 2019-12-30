# frozen_string_literal: true

class SubjectCategory < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  has_many :subjects, dependent: :restrict_with_error

  validates :name, presence: true,
                   length: { in: (0..100) }
  validates :code, presence: true,
                   length: { is: 1 },
                   format: { with: /[A-Z]/, multiline: true }
end
