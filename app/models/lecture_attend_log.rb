# frozen_string_literal: true

class LectureAttendLog < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true

  belongs_to :lecture
  belongs_to :student, optional: true

  def prepare_validation_note
    # append_validation_note('古すぎます') if Time.zone.now > qr_made_at + 10.days
    append_validation_note('学生IDが一致しません') if prev_cookie_student_ids.present? && student_id.to_s != prev_cookie_student_ids
    # append_validation_note('複数回目') if lecture.lecture_attend_logs.where(student_id: student_id).count.positive?
  end

  def append_validation_note(value)
    self.validation_note = validation_note.present? ? "#{validation_note}, #{value}" : value.to_s
  end
end
