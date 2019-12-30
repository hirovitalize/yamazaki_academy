# frozen_string_literal: true

class Area < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :province
  has_many :buildings, dependent: :restrict_with_error
  has_many :klasses, dependent: :restrict_with_error
  has_many :students, dependent: :restrict_with_error

  validates :name, presence: true,
                   length: { in: (0..100) }
  validates :code, presence: true,
                   length: { is: 2 },
                   format: { with: /[0-9]/, multiline: true }
end
