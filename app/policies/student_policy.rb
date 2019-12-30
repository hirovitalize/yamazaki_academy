# frozen_string_literal: true

class StudentPolicy < ApplicationPolicy
  ROLE_NAMES = ['STUDENT_ADMIN'].freeze

  alias choose_merging? with_role?
  alias change_normalized? with_role?
  alias compare_merging? with_role?
  alias merge? with_role?
  alias import? with_role?
end
