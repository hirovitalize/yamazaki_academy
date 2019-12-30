# frozen_string_literal: true

class KlassSubjectPolicy < ApplicationPolicy
  ROLE_NAMES = ['MASTER_CONTROL'].freeze

  def delete_lectures?
    with_role? 'STUDENT_ADMIN'
  end

  def fix?
    with_role? 'STUDENT_ADMIN'
  end

  alias unfix? fix?
end
