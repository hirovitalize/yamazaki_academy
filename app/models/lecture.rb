# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Lecture < ApplicationRecord
  include AASM
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail ignore: [:cached_tag_list]
  acts_as_taggable_on :tags

  include HasDatetimeRange
  acts_as_datetimerange :start_time, :finish_time, as: :lecture, include_to: false

  # Home画面で使用する定数
  KIND_SUBJECT_VIP = 'vip'
  KIND_SUBJECT_FIRST_VIP = 'first_vip'
  KIND_SUBJECT_GROUP = 'group'
  KIND_SUBJECT = [KIND_SUBJECT_VIP, KIND_SUBJECT_FIRST_VIP, KIND_SUBJECT_GROUP].freeze

  has_one :reserve, dependent: :destroy, autosave: true
  belongs_to :confirmer, optional: true, class_name: 'User'
  belongs_to :klass_subject, optional: true
  belongs_to :subject, optional: true
  has_one :klass, through: :klass_subject
  has_many :lecture_students, dependent: :destroy
  has_many :lecture_staffs, dependent: :destroy
  has_many :staffs, through: :lecture_staffs
  has_many :students, through: :lecture_students
  # rubocop:disable all
  has_many :lecture_attend_logs
  # rubocop:enable all

  scope :reserved, -> { joins(:reserve) }
  scope :not_reserved, -> { left_joins(:reserve).where(reserves: { id: nil }) }
  scope :not_canceled, -> { left_joins(:reserve).where(lectures: { canceled_status: nil }) }

  scope :refine_vip, -> { where(subject_id: Subject::VIP) }
  scope :refine_first_vip, -> { where.not(subject_id: Subject::VIP).where(subject_id: [Subject::ART_VIP, Subject::FACULTY_VIP, Subject::MASTER_VIP]) }
  scope :refine_group, -> { where(subjects: { personal: false }) }
  scope :is_confirmed, -> { where(confirmed: true) }

  enum confirmed: { approved: 1, unapproved: -1, notyet: 0 }, _prefix: true
  enum canceled_status: ::HashUtil.from_keys(%w[cancel cancel_today_contact cancel_no_contact]), _prefix: true

  validates :name, presence: true,
                   length: { in: (0..100) }
  validates :start_time, timeliness: { on_or_before: :finish_time, type: :datetime },
                         presence: true
  validates :finish_time, timeliness: { type: :datetime },
                          presence: true

  validate :check_interval_time
  validate :check_makeable_time
  validate :check_time_with_reserve

  # validate :check_student_rest_hours

  validates :confirmed_at, timeliness: { type: :datetime },
                           presence: true,
                           unless: :confirmed_notyet?
  # validates :confirmed_at, absence: true, if: :confirmed_notyet?
  # validates :confirmer, presence: true, unless: :confirmed_notyet?
  validates :confirmer, absence: true, if: :confirmed_notyet?

  validates :subject, presence: true

  validates_associated :students
  validates_associated :lecture_staffs

  after_initialize :default_values, if: :new_record?
  around_save :sync_points_and_salaries, if: :confirmed_changed?
  after_update :sync_student_point

  aasm column: :confirmed, enum: true, create_scopes: false, whiny_transitions: false do
    state :notyet, initial: true, before_enter: :reset_stamp_approved
    state :approved, before_enter: :stamp_approved
    state :unapproved, before_enter: :stamp_approved

    event :approve do
      transitions from: :notyet, to: :approved
    end
    event :unapprove do
      transitions from: :notyet, to: :unapproved
    end
    event :back_confirmed do
      transitions from: %i[approved unapproved], to: :notyet
    end
  end

  def to_label
    "#{canceled_status.present? ? canceled_status_i18n : ''}#{super}"
  end

  def self.not_reserved
    all.left_outer_joins(:reserve).where(reserves: { id: nil })
  end

  def self.not_canceled
    all.left_outer_joins(:reserve).where(lectures: { canceled_status: nil })
  end

  def self.not_klass_subject_not_pesonal
    all.left_outer_joins(:subject).where(klass_subject_id: nil).where(subjects: { personal: false })
  end

  def self.without_staff_work_kind(work_kind_id)
    # SELECT  `lectures`.* FROM `lectures`
    # WHERE NOT (EXISTS (
    #       SELECT `lecture_staffs`.* FROM `lecture_staffs`
    #       WHERE  `lecture_staffs`.`lecture_id` = `lectures`.`id` AND `lecture_staffs`.`work_kind_id` IN (1)
    # ))
    lecture_table = arel_table
    lecture_staff_table = LectureStaff.arel_table
    condition = lecture_staff_table[:lecture_id].eq(lecture_table[:id]).and(lecture_staff_table[:work_kind_id].in(work_kind_id))

    all.where(LectureStaff.where(condition).exists.not)
  end

  def self.with_staff_double_booking
    all.left_outer_joins(:lecture_staffs).where(
      'EXISTS (' \
      ' select 1 from lecture_staffs ls2' \
      ' where DATE(lecture_staffs.start_time) = DATE(ls2.start_time)' \
      '     and ls2.deleted_at is null' \
      '     and ls2.lecture_id != lecture_staffs.lecture_id' \
      '     and ls2.staff_id = lecture_staffs.staff_id' \
      '     and not (' \
      '     (lecture_staffs.start_time >= ls2.start_time and lecture_staffs.start_time > ls2.finish_time )' \
      '     or (lecture_staffs.finish_time <= ls2.start_time and lecture_staffs.start_time < ls2.finish_time )' \
      '))'
    )
  end

  def hours
    ((finish_time - start_time) / 1.hour).to_d
  end

  def student_point_hours
    return 0 if canceled_status_cancel?
    return 1 if canceled_status_cancel_today_contact?
    return hours.to_f if canceled_status_cancel_no_contact?

    hours.to_f
  end

  def past?
    finish_time < Time.zone.now
  end

  def updateable_time?
    # 「授業月」か「授業月 == (本日日付 - 3.days)月」か「現在の時間よりも、未来の授業時間」
    return true if finish_time.end_of_month >= Time.zone.now.end_of_month
    return true if finish_time.end_of_month == (Time.zone.now - 3.days).end_of_month

    false
  end

  def vip_updateable_time?
    return true unless ((start_time.yesterday.end_of_day - Time.zone.now) / 1.hour).to_i < 9
    return true if start_time <= Time.zone.now && Time.zone.now <= finish_time + 1.hour

    false
  end

  def vip_lecture_creatable_time?
    ((start_time.yesterday.end_of_day - Time.zone.now) / 1.hour).to_i > 9
  end

  def duplicate_after(days)
    l = dup
    l.start_time = start_time + days
    l.finish_time = finish_time + days
    l.back_confirmed
    l.students = students
    lecture_staffs.each do |ls|
      l.lecture_staffs.build(
        staff_id: ls.staff_id,
        work_kind_id: ls.work_kind_id,
        start_time: ls.start_time + days,
        finish_time: ls.finish_time + days
      )
    end

    l.save!
  end

  def cancel!(cancel_status)
    self.canceled_status = cancel_status
    self&.reserve&.destroy!
    save!
  end

  # ホームカレンダー基盤の授業群を抽出
  def self.get_home_lectures(staff_id, target_time)
    Lecture.all.includes(:lecture_staffs, :subject)
           .where(lecture_staffs: { staff_id: staff_id })
           .where('canceled_status IS NULL OR canceled_status <> ?', 'cancel')
           .where(start_time: target_time.beginning_of_month..target_time.end_of_month)
  end

  # rubocop:disable all
  def get_home_each_lecture(lecture_table, is_last_month, kind)
    if is_last_month && Time.zone.now.beginning_of_month + 4.days <= Time.zone.now
      return lecture_table.refine_vip.is_confirmed if kind == KIND_SUBJECT_VIP
      return lecture_table.refine_first_vip.is_confirmed if kind == KIND_SUBJECT_FIRST_VIP
      return lecture_table.refine_group.is_confirmed if kind == KIND_SUBJECT_GROUP
    else
      return lecture_table.refine_vip if kind == KIND_SUBJECT_VIP
      return lecture_table.refine_first_vip if kind == KIND_SUBJECT_FIRST_VIP
      return lecture_table.refine_group if kind == KIND_SUBJECT_GROUP
    end
  end
  # rubocop:enable all

  def time_for_each_month(lectures, staff_id)
    result_array = {}
    result_array['this'] = calc_time(lectures, false)
    result_array['last'] = calc_time(Lecture.get_home_lectures(staff_id, Time.zone.now.prev_month), true)

    result_array
  end

  # ホームカレンダー時間計算
  def calc_time(target_lectures, is_last_month)
    result_data = {}
    KIND_SUBJECT.each do |kind|
      lectures = get_home_each_lecture(target_lectures, is_last_month, kind)

      total_time = 0
      lectures.map do |lecture|
        lecture.lecture_staffs.map do |ls|
          total_time += lecture.canceled_status == 'cancel_no_contact' || lecture.canceled_status == 'cancel_today_contact' ? 1 : ls.hours.to_f
        end
      end
      result_data[kind] = total_time.to_s
    end
    result_data
  end

  private

  def stamp_approved
    self.confirmer = self.class.stamper_class.stamper
    self.confirmed_at = Time.zone.now
  end

  def reset_stamp_approved
    self.confirmer = nil
    self.confirmed_at = nil
  end

  def default_values
    self.confirmed = :notyet if confirmed.blank?
    self.time_changeable = false if time_changeable.nil?
  end

  def sync_points_and_salaries
    yield

    success = confirmed_approved?
    # 学生時間数:同期
    students.each do |st|
      st.student_point.sync_used
      st.student_point.sync_reserved
    end

    # 講師時間数:確定
    lecture_staffs.each do |ls|
      staff_hours = success ? ls.staff_hours : nil
      ls.update(confirmed_staff_hours: staff_hours)
    end

    # VIP消費時間数:確定
    lecture_students.each do |ls|
      student_pointed = success ? (student_point_hours * 60).to_i : nil
      ls.update(confirmed_point: student_pointed)
    end
  end

  def sync_student_point
    return unless subject&.personal?
    return if lecture_students.blank?
    return unless start_time == start_time_was || finish_time == finish_time_was
    return if confirmed_changed?

    lecture_students.map do |lecture_student|
      lecture_student.student.student_point.sync_used
      lecture_student.student.student_point.sync_reserved
    end
  end

  def check_interval_time
    # 2019/11/01からVIPについては授業時間が30分単位のルール
    return if finish_time.blank?
    return if start_time.blank?
    return unless subject&.personal?
    return if finish_time < '2019/11/01 00:00'

    errors[:base] << '授業時間は30分単位にしてください' unless (((finish_time - start_time) / 60) % 30).zero?
  end

  def check_makeable_time
    return if finish_time.blank?
    return if start_time.blank?

    errors[:base] << '月締め(月初2日)後は、前月以前の日程は作成できません' unless updateable_time?
  end

  # 一旦削除
  # def check_student_rest_hours
  #   return unless subject_id == Subject::VIP
  #   return if lecture_students.blank?
  #   return if finish_time.blank?
  #   return if start_time.blank?

  #   lecture_students.each do |lecture_student|
  #     student_pointt = lecture_student&.student&.student_point
  #     errors.add(:students, 'のVIP時間数が足りません') if (student_pointt&.total.to_f / 60 - student_pointt&.used.to_f / 60 - hours.to_f).negative?
  #   end
  # end

  def check_time_with_reserve
    return if reserve.blank?
    return if start_time.blank?
    return if finish_time.blank?
    return if reserve.marked_for_destruction?

    errors.add(:start_time, "は#{Reserve.model_name.human}と一致しません。予約を解除して時間変更を実施したのち、再度予約してください") if start_time != reserve.start_time
    errors.add(:finish_time, "は#{Reserve.model_name.human}と一致しません。予約を解除して時間変更を実施したのち、再度予約してください") if finish_time != reserve.finish_time
  end
end
# rubocop:enable Metrics/ClassLength
