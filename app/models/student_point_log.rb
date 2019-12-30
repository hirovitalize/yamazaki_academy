# frozen_string_literal: true

class StudentPointLog < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :lecture_student, optional: true
  belongs_to :student

  validates :kind, presence: true
  validates :detail, presence: true,
                     length: { in: (0..100) }
  validates :log, presence: true
  validates :point, presence: true

  # コンバートのみ。今後使用しない。
end
