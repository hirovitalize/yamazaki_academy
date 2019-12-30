# frozen_string_literal: true

class RoomRoomGroup < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :room_group
  belongs_to :room

  validates :room, uniqueness: { scope: %i[room_group deleted_at] }
end
