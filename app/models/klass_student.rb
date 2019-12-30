# frozen_string_literal: true

class KlassStudent < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :student
  belongs_to :klass
end
