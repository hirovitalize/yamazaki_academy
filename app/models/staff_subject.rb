# frozen_string_literal: true

class StaffSubject < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :staff
  belongs_to :subject
end
