# frozen_string_literal: true

class InflowSource < ApplicationRecord
  include ParanoiaVisible
  stampable with_deleted: true
  has_paper_trail

  # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :student_commission
  # rubocop:enable Rails/HasManyOrHasOneDependent
end
