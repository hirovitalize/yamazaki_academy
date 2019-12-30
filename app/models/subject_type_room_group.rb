# frozen_string_literal: true

class SubjectTypeRoomGroup < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :subject_type
  belongs_to :room_group
end
