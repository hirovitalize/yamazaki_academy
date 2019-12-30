# frozen_string_literal: true

class CourseKlassTemplate < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :course
  belongs_to :klass_template
end
