# frozen_string_literal: true

class Province < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  has_many :areas, dependent: :restrict_with_error

  validates :code, presence: true,
                   length: { is: 2 },
                   format: { with: /[A-Z]/ }
end
