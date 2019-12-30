# frozen_string_literal: true

class RoomGroup < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  has_many :room_room_groups, dependent: :restrict_with_error
  has_many :rooms, through: :room_room_groups
  has_many :subject_type_room_groups, dependent: :restrict_with_error

  validates :name, presence: true,
                   length: { in: (0..100) }
end
