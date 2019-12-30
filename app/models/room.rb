# frozen_string_literal: true

class Room < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :building, optional: true
  has_many :room_room_groups, dependent: :destroy
  has_many :room_equipments, dependent: :destroy
  has_many :room_groups, through: :room_room_groups
  has_many :equipments, through: :room_equipments
  has_many :reserves # rubocop:disable Rails/HasManyOrHasOneDependent

  validates :name, presence: true,
                   length: { in: (0..100) }
  validates :seat_number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # TODO: validates :room_groups  kind_building? は、複数設定できない
  # TODO: validates :room_groups  kind_building? は、必ず1つ

  def to_label
    n = super
    n += "(#{building&.name})" if building.present?
    n
  end

  accepts_nested_attributes_for :room_equipments, reject_if: :all_blank, allow_destroy: true
end
