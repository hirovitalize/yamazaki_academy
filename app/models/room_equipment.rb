# frozen_string_literal: true

class RoomEquipment < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :equipment
  belongs_to :room

  after_initialize :default_values, if: :new_record?

  def self.available
    where(available: true)
  end

  private

  def default_values
    self.available = true if available.nil?
  end
end
