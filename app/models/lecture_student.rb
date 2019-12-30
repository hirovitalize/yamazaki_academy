# frozen_string_literal: true

class LectureStudent < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :lecture, inverse_of: :lecture_students
  belongs_to :student, inverse_of: :lecture_students

  validates :confirmed_point, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true

  after_create :sync_student_point
  after_destroy :sync_student_point

  private

  def sync_student_point
    student.build_student_point if student.student_point.blank?
    student.student_point.sync_reserved
  end
end
