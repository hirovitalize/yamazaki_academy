# frozen_string_literal: true

class KlassTemplate < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :course_category

  has_many :course_klass_templates, dependent: :destroy
  has_many :courses, through: :course_klass_templates

  has_many :klass_template_subjects, dependent: :restrict_with_error
  has_many :subjects, through: :klass_template_subjects
  has_many :klasses, dependent: :restrict_with_error

  validates :name, presence: true,
                   length: { in: (0..100) }

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

  private

  def default_values
    self.interval = 180 if interval.blank?
  end
end
