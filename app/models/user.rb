# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, # :registerable,
         :recoverable, :trackable, :validatable,
         :lockable, :confirmable, :rememberable
  # Include default devise modules. Others available are:
  # :timeoutable,   :omniauthable

  has_secure_token :auth_token

  model_stamper
  acts_as_paranoid
  stampable with_deleted: true, optional: true
  # loginの際には履歴を生成しない
  has_paper_trail ignore: %i[
    current_sign_in_at last_sign_in_at
    current_sign_in_ip last_sign_in_ip
    sign_in_count
    reset_password_token reset_password_sent_at remember_created_at
    updater_id updated_at
    auth_token
  ]

  COMMON = 2

  has_one :staff # rubocop:disable Rails/HasManyOrHasOneDependent

  validates :staff, presence: true, unless: :common?
  validates :auth_token, uniqueness: true, allow_blank: true
  validates :name, presence: true
  validates :email, presence: true,
                    format: { with: EmailFormatValidator::CODE_REGEX, allow_blank: true },
                    uniqueness: { scope: [:deleted_at] }
  validate :check_password, if: :encrypted_password_changed?

  def self.locked
    all.where.not(locked_at: nil)
  end

  def self.common
    all.where(id: User::COMMON)
  end

  def password_required?
    false
  end

  def name
    staff.try(:name).presence || 'Who am I?'
  end

  def role?(code)
    return false if staff.blank?

    (staff.roles.select { |r| r.code == code }).present?
  end

  def common?
    id == COMMON
  end

  private

  def check_password
    return if password.blank?

    errors.add(:password, 'は数字を含んでください') unless /[0-9]/ =~ password
    errors.add(:password, 'は英字を含んでください') unless /[a-zA-Z]/ =~ password
  end
end
