# frozen_string_literal: true

class Klass < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  include HasDateRange
  acts_as_daterange :start_date, :finish_date, include_to: false

  belongs_to :area, optional: true # null: オンラインなど場所
  belongs_to :klass_template
  has_many :klass_students, dependent: :restrict_with_error
  has_many :students, through: :klass_students
  has_many :klass_subjects, dependent: :restrict_with_error
  has_many :subjects, through: :klass_subjects
  has_many :shared_klass_klass_subjects, dependent: :destroy
  has_many :sharing_klass_subjects, through: :shared_klass_klass_subjects, source: :klass_subject

  validates :name, presence: true,
                   length: { in: (0..100) }
  validates :start_date, timeliness: { on_or_before: :finish_date, type: :date }, presence: true
  validates :finish_date, timeliness: { type: :date }, presence: true
  validates :code, presence: true,
                   length: { is: 6 },
                   format: { with: /[A-Z]{2}[0-9]{4}/, multiline: true }

  validates :lecture_num, numericality: { only_integer: true,
                                          greater_than_or_equal_to: 1,
                                          less_than: 100 },
                          allow_blank: true
  validates :interval, numericality: { only_integer: true,
                                       greater_than_or_equal_to: 1,
                                       less_than: 86_400 },
                       allow_blank: true

  validates :hours, numericality: { greater_than: 0,
                                    less_than: 24.0 },
                    allow_blank: true

  validates_associated :students

  after_initialize :default_values, if: :new_record?

  def hours
    interval.to_f / 60
  end

  def hours=(value)
    self.interval = (value.to_f * 60.to_f).floor
  end

  def total_hours
    (hours.to_f * lecture_num).floor
  end

  def self.current
    date_range_included(Time.zone.now)
  end

  def change_lectures_name
    klass_subjects.each do |klass_subject|
      klass_subject.lectures.each do |lecture|
        next if lecture.start_time < Time.zone.now

        lecture.name = "#{name} #{klass_subject.subject&.name}"
        lecture.save!
      end
    end
  end

  def code_with_area_year
    prov = area&.province&.code || 'XX'
    year = start_date.strftime('%y')

    "#{prov}#{year}---#{code}"
  end

  private

  def default_values
    self.code = 'XX9999' if code.blank?
    self.lecture_num = klass_template&.lecture_num.presence if lecture_num.blank?
    self.interval = (klass_template&.interval.presence || 180) if interval.blank?
  end
end
