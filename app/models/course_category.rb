# frozen_string_literal: true

class CourseCategory < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  has_many :courses, dependent: :restrict_with_error
  has_many :klass_templates, dependent: :restrict_with_error
  has_many :course_category_students, dependent: :destroy
  has_many :students, through: :course_category_students

  validates :name, presence: true,
                   length: { in: (0..100) }
end
