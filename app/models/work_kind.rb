# frozen_string_literal: true

class WorkKind < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  ID_TEACHER = 1
  ID_TRANSLATOR = 2
  ID_TA = 3
  ID_INTERVIEWER = 4
  ID_APPLYER = 5

  has_many :lecture_staffs # rubocop:disable Rails/HasManyOrHasOneDependent

  validates :name, presence: true, length: { in: (1..100) }
end
