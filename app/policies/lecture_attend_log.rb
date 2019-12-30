# frozen_string_literal: true

class LectureAttendLogPolicy < ApplicationPolicy
  ROLE_NAMES = ['STUDENT_ADMIN'].freeze

  alias index? with_role?
  alias show? with_role?
end
