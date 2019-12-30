# frozen_string_literal: true

class StaffRole < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :role
  belongs_to :staff
end
