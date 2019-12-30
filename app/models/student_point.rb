# frozen_string_literal: true

class StudentPoint < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail
  include OptimisticLockValidatable

  belongs_to :student

  validates :total, numericality: { only_integer: true, greater_than_or_equal_to: 0 } # <- StudentBilling(VIP)
  validates :paid, numericality: { only_integer: true, greater_than_or_equal_to: 0 } # <- 今後使用しない StudentBallanceから見る
  validates :used, numericality: { only_integer: true, greater_than_or_equal_to: 0 } # <- 承認済み lecture_student
  validates :reserved, numericality: { only_integer: true, greater_than_or_equal_to: 0 } #

  %i[total paid used reserved].each do |field|
    method = "#{field}_hours"
    validates method, numericality: { greater_than_or_equal_to: 0 }

    define_method(method) do
      format('%.2f', public_send(field).to_f / 60.to_f)
    end

    define_method("#{method}=") do |value|
      public_send "#{field}=", (60.to_f * value.to_f).floor
    end
  end

  after_initialize :default_values, if: :new_record?
  before_validation :default_values

  def name
    "残時間: #{format('%.2f', rest_hours.to_f)} h"
  end

  def rest_hours
    total_hours.to_d - reserved_hours.to_d
  end

  def total_hours_minus_used_hours
    total_hours.to_d - used_hours.to_d
  end

  def sync_used
    scope_confirmed = student.lectures.confirmed_approved.includes(:subject).where(subjects: { id: Subject::VIP })
    update(used: target_points(scope_confirmed))
  end

  def sync_reserved
    scope_not_confirmed = student.lectures.includes(:subject).where(subjects: { id: Subject::VIP })
    update(reserved: target_points(scope_not_confirmed))
  end

  private

  def target_points(scoping)
    scoping.includes(:lecture_students).map do |lect|
      confirmed_point = (lect.lecture_students.select { |ls| ls.student_id == student_id }).first&.confirmed_point
      confirmed_point.present? ? confirmed_point : (lect.student_point_hours * 60)
    end.sum.floor
  end

  def default_values
    self.total = 0 if total.nil?
    self.paid = 0 if paid.nil?
    self.used = 0 if used.nil?
    self.reserved = 0 if reserved.nil?
  end
end
