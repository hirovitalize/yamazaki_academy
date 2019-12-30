# frozen_string_literal: true

class Equipment < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  has_many :room_equipments, dependent: :restrict_with_error
  has_many :rooms, through: :room_equipments

  validates :name, presence: true,
                   length: { in: (0..100) }
end
