# frozen_string_literal: true

class LectureStaff < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  include HasDatetimeRange
  acts_as_datetimerange :start_time, :finish_time, as: :lecture_staff, include_to: false

  belongs_to :staff
  belongs_to :lecture
  belongs_to :work_kind

  validates :confirmed_staff_hours, numericality: true, allow_blank: true
  validate :check_interval_time_for_staff
  validate :check_time_within_lecture_time

  before_validation :copy_time_range_from_lecture

  after_save :register_mentee_in_student_mentor

  def self.by_lecture_month(date)
    date = Time.zone.parse(date) if date.is_a?(String)
    all.joins(:lecture).where(lectures: { start_time: date.all_month })
  end

  def hours
    ((finish_time - start_time) / 1.hour).to_d
  end

  def staff_hours
    return confirmed_staff_hours unless confirmed_staff_hours.nil?

    return 0 if lecture.canceled_status_cancel?
    return 1 if lecture.canceled_status_cancel_today_contact?
    return 1 if lecture.canceled_status_cancel_no_contact?

    hours.to_f
  end

  private

  def register_mentee_in_student_mentor
    return unless lecture.subject.personal
    return if lecture.lecture_students.blank?
    return if staff.student_mentors.map(&:student_id).include?(lecture.lecture_students.first.student.id)

    StudentMentor.create(student_id: lecture.lecture_students.first.student.id, staff_id: staff_id)
  end

  def check_interval_time_for_staff
    # 2019/11/01からVIPについては授業時間が30分単位のルール
    return if finish_time.blank?
    return if start_time.blank?
    return unless lecture.subject&.personal?
    return if finish_time < '2019/11/01 00:00'

    errors.add(:finish_time, 'を30分単位になるように調整してください') unless (((finish_time - start_time) / 60) % 30).zero?
  end

  def check_time_within_lecture_time
    return if finish_time.blank?
    return if start_time.blank?
    return if lecture.finish_time.blank?
    return if lecture.start_time.blank?

    errors.add(:start_time, "は#{lecture.start_time}より大きくしてください") unless start_time >= lecture.start_time && start_time < lecture.finish_time
    errors.add(:finish_time, "は#{lecture.finish_time}より小さくしてください") unless finish_time <= lecture.finish_time && finish_time > lecture.start_time
  end

  def copy_time_range_from_lecture
    self.start_time = lecture.start_time if start_time.blank?
    self.finish_time = lecture.finish_time if finish_time.blank?
  end

  def default_values
    self.work_kind_id ||= WorkKind::ID_TEACHER
  end
end
