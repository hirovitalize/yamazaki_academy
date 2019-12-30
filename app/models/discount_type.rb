# frozen_string_literal: true

class DiscountType < ApplicationRecord
  include ParanoiaVisible
  stampable with_deleted: true
  has_paper_trail

  # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :student_billings # dependent: nothing
  # rubocop:enable Rails/HasManyOrHasOneDependent

  validates :name, presence: true, length: { in: (0..100) }
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true
  validates :rate, numericality: { only_integer: true,
                                   greater_than_or_equal_to: 0,
                                   less_than_or_equal_to: 100 },
                   allow_blank: true
  validates :rate, absence: true, if: -> { price&.positive? }
  validates :price, absence: true, if: -> { rate&.positive? }
end
