# frozen_string_literal: true

class Role < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  SYSTEM_ADMIN = 'SYSTEM_ADMIN'

  has_many :staff_roles, dependent: :restrict_with_error
  has_many :staffs, through: :staff_roles

  validates :code, presence: true, format: { with: /[A-Z_]/,
                                             message: '半角英数字＆記号のみ使用可能' }

  validates :name, presence: true,
                   length: { in: (0..100) }
end
