# frozen_string_literal: true

class StudentMycoach < ApplicationRecord
  devise :lockable

  has_secure_token :auth_token

  model_stamper
  acts_as_paranoid
  stampable with_deleted: true, optional: true

  belongs_to :student

  validates :email, allow_blank: true,
                    format: { with: EmailFormatValidator::CODE_REGEX },
                    uniqueness: { scope: [:deleted_at] }

  def name
    student.try(:name).presence || 'Who am I?'
  end
end
