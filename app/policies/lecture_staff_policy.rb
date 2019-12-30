# frozen_string_literal: true

class LectureStaffPolicy < ApplicationPolicy
  ROLE_NAMES = %w[STAFF_ADMIN STUDENT_ADMIN].freeze
end
