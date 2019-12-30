# frozen_string_literal: true

module OptimisticLockValidatable
  extend ActiveSupport::Concern

  # How to use.
  #
  # models
  #  include OptimisticLockValidatable
  #
  # add forms
  #  = f.input :lock_version, as: :hidden
  #  = f.hidden_field :lock_version
  #
  # db schema
  #  t.integer 'lock_version', default: 0, null: false

  included do
    around_save :save_with_optimistic_lock
  end

  protected

  def save_with_optimistic_lock
    yield
  rescue ActiveRecord::StaleObjectError
    self.lock_version = lock_version_was
    errors.add :base, build_conflicting_message
    changes.except(:updated_at, :updater_id).each do |name, values|
      errors.add name, " [競合] #{values.first}"
    end
    false
  end

  def build_conflicting_message
    mesg = 'あなたが編集中に他の方の更新がありました。'
    mesg += " 更新日時: #{updated_at}" if updated_at.present?
    mesg += " 更新者: #{updater.try(:name)}" if updater.present?
    mesg
  end
end
