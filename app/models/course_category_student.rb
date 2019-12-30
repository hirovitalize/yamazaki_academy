# frozen_string_literal: true

class CourseCategoryStudent < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :student
  belongs_to :course_category
end
