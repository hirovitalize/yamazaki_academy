# frozen_string_literal: true

class CacheBackType < ApplicationRecord
  include ParanoiaVisible
  stampable with_deleted: true
  has_paper_trail

  # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :student_commissions # dependent: nothing
  # rubocop:enable Rails/HasManyOrHasOneDependent

  validates :name, presence: true, length: { in: (0..100) }
end
