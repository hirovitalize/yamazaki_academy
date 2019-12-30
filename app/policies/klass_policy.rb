# frozen_string_literal: true

class KlassPolicy < ApplicationPolicy
  ROLE_NAMES = ['MASTER_CONTROL'].freeze

  alias duplicate? new?
end
