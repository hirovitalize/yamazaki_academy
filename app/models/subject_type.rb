# frozen_string_literal: true

# TODO: 現状未使用。データ不適切のため
class SubjectType < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  has_many :subjects, dependent: :restrict_with_error
  has_many :subject_type_room_groups, dependent: :restrict_with_error
  has_many :available_room_groups, through: :subject_type_room_groups, class_name: 'RoomGroup', source: :room_group

  validates :name, presence: true,
                   length: { in: (0..100) }
  validates :color, presence: true, format: { with: /\#+[a-f1-9]{6}/,
                                              message: '16進数の6桁のみが使用できる' }
end
