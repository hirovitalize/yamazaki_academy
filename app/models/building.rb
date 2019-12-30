# frozen_string_literal: true

class Building < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :area
  has_many :rooms, dependent: :restrict_with_error

  validates :name, presence: true,
                   length: { in: (0..100) }
end
