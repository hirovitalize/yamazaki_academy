# frozen_string_literal: true

class JapaneseSchool < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :students
  # rubocop:enable Rails/HasManyOrHasOneDependent

  validates :name, presence: true,
                   uniqueness: { scope: :deleted_at },
                   length: { in: (0..100) }
end
