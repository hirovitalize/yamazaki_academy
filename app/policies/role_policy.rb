# frozen_string_literal: true

class RolePolicy < ApplicationPolicy
  ROLE_NAMES = ['ROLE_CONTROL'].freeze

  alias index? with_role?
  alias show? with_role?
end
