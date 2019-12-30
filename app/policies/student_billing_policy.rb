# frozen_string_literal: true

class StudentBillingPolicy < ApplicationPolicy
  ROLE_NAMES = ['PAYMENT'].freeze

  # @overwrite
  def destroy?
    with_role? ['PAYMENT_ADMIN']
  end
end
