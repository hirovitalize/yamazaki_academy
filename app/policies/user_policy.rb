# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  ROLE_NAMES = ['STAFF_ADMIN'].freeze

  alias index? with_role?
  alias show? with_role?
  alias lock? with_role?
  alias unlock? with_role?
end
