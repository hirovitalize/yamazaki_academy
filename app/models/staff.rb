# frozen_string_literal: true

class Staff < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :user
  has_many :student_mentors, dependent: :restrict_with_error
  has_many :lecture_staffs, dependent: :destroy
  has_many :staff_roles, dependent: :destroy
  has_many :staff_subjects, dependent: :destroy
  has_many :lectures, through: :lecture_staffs
  has_many :roles, through: :staff_roles
  has_many :mentees, through: :student_mentors, source: :student
  has_many :subjects, through: :staff_subjects
  # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :acquired_students, class_name: 'Student'
  # rubocop:enable Rails/HasManyOrHasOneDependent

  scope :sales, -> { joins(:roles).where(roles: { code: 'SALES' }) }

  validates :code, uniqueness: { allow_blank: true, conditions: -> { with_deleted } }
  validates :name, presence: true,
                   length: { in: (0..100) }
  validates :tel, phone_format: true
  validates :birthday, timeliness: { type: :date, before: :today }, allow_blank: true

  after_initialize :default_values, if: :new_record?
  before_save :change_code_to_nil
  accepts_nested_attributes_for :user, reject_if: :all_blank, allow_destroy: true

  delegate :email, to: :user

  private

  def default_values
    build_user if user.blank?
  end

  def change_code_to_nil
    self.code = nil if code.blank?
  end
end
