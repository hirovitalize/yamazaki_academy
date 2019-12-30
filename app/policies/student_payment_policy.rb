# frozen_string_literal: true

class StudentPaymentPolicy < ApplicationPolicy
  ROLE_NAMES = ['PAYMENT'].freeze

  # @overwrite
  def destroy?
    with_role? ['PAYMENT_ADMIN']
  end
end
