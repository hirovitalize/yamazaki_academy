# frozen_string_literal: true

class Subject < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  VIP = 2
  FACULTY_VIP = 153
  MASTER_VIP = 154
  ART_VIP = 155
  RESEARCH_PLAN_VIP = 168
  DESIRED_REASON_COACH_VIP = 169
  SHAM_INTERVIEW_COACH_VIP = 170
  SHORT_ESSAY_VIP = 171
  SHAM_INTERVIEW_VIP = 172
  DESIRED_REASON_VIP = 173

  belongs_to :subject_category
  belongs_to :subject_type, optional: true
  has_many :lectures, dependent: :restrict_with_error
  has_many :klass_subjects, dependent: :restrict_with_error
  has_many :klass_template_subjects, dependent: :restrict_with_error
  has_many :klass_templates, through: :klass_template_subjects
  has_many :staff_subjects, dependent: :restrict_with_error
  has_many :staffs, through: :staff_subjects

  validates :name, presence: true,
                   length: { in: (0..100) }

  validates :code, presence: true,
                   length: { is: 3 },
                   format: { with: /[A-Z][0-9][0-9]/, multiline: true }

  validate :check_subject_category_code

  after_initialize :default_values, if: :new_record?

  private

  def check_subject_category_code
    return if subject_category.blank?
    return if code.blank?

    code_head = code.slice(0)
    errors.add(:code, "の先頭は、#{SubjectCategory.model_name.human} に合わせて「#{subject_category.code}」としてください") if code_head != subject_category.code
  end

  def default_values
    self.personal = false if personal.nil?
  end
end
