# frozen_string_literal: true

class StudentMentorPolicy < ApplicationPolicy
  def update?
    return true if user.staff.id == record.staff_id
    return true if user.role? 'STAFF_ADMIN'

    false
  end

  alias edit? update?
  alias destroy? update?
end
