# frozen_string_literal: true

class StudentMentor < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :staff
  belongs_to :student

  enum staff_type: ::HashUtil.from_keys(%w[administration art]), _prefix: true

  validates :student_id, uniqueness: { scope: %i[deleted_at staff_id staff_type] }
end
