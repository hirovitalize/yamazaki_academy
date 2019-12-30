# frozen_string_literal: true

class KlassSubject < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :klass
  belongs_to :staff, optional: true
  belongs_to :subject
  has_many :lectures, dependent: :restrict_with_error
  has_many :shared_klass_klass_subjects, dependent: :destroy
  has_many :sharing_klasses, through: :shared_klass_klass_subjects, source: :klass

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

  validates :code, presence: true
  # TODO: Code書式のValidation
  # TODO: shared_klasses と klassesのバッティング

  after_initialize :default_values, if: :new_record?
  before_validation :build_code

  def name
    return if subject.blank?
    return if klass.blank?

    "#{subject.name}[#{klass.name}]"
  end

  # 通常クラス + 共同クラス
  def klasses
    ([klass] + sharing_klasses).compact
  end

  def finish_time
    start_time. + interval.minutes
  end

  def hours
    interval.to_f / 60
  end

  def hours=(value)
    self.interval = (value.to_f * 60.to_f).floor
  end

  def total_hours
    (hours.to_f * lecture_num).floor
  end

  def lecture_appendable?
    return true if lecture_num.nil?

    lecture_num > lectures.count
  end

  private

  def build_code
    return if code.present?
    return if subject.blank?
    return if klass.blank?

    self.code = format(
      '%<prov>2s%<year>2d%<subj>3s%<klass>6s',
      prov: klass.area&.province&.code || 'XX',
      year: klass.start_date.strftime('%y'),
      subj: subject.code,
      klass: klass.code
    )
  end

  def default_values
    self.lecture_num = klass&.lecture_num.presence if lecture_num.blank?
    self.interval = (klass&.interval.presence || 180) if interval.blank?
    build_code
  end
end
