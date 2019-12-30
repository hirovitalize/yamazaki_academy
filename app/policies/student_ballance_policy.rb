# frozen_string_literal: true

class StudentBalancePolicy < ApplicationPolicy
  ROLE_NAMES = %w[PAYMENT PAYMENT_ADMIN].freeze

  alias index? with_role?
  alias show? with_role?
end
