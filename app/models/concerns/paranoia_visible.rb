# frozen_string_literal: true

module ParanoiaVisible
  extend ActiveSupport::Concern

  included do
    acts_as_paranoid without_default_scope: true

    # 削除済みの状態では編集不可
    validate :check_deleted

    # 新規データに削除済みデータを割り当てるのは禁止
    # 関連先に、以下のValidationを追加する
    # validates :assoc, without_deleted: true

    #    around_save :save_with_readonly

    # 削除済みなので、DB変更不可
    # 保存時に、ActiveRecord::ReadOnlyRecord が発生します。
    #    def readonly?
    #      return true if deleted? && !deleted_at_changed?
    #
    #      super
    #    end

    def self.without_deleted_unless_already_assigned(model)
      return without_deleted if model.new_record?
      return without_deleted unless assigned_me?(model)

      with_deleted
    end

    def self.assigned_me?(model)
      assoc, _macro = model.class.reflections.find { |_k, m| m.klass == self }
      return false if assoc.blank?

      value = model.send(assoc)
      return false if value.blank?

      return value.first.respond_to?(:deleted?) && value.any?(&:deleted?) if value.is_a?(Enumerable)

      value.respond_to?(:deleted?) && value.deleted?
    end
  end

  protected

  #  def save_with_readonly
  #    yield
  #  rescue ActiveRecord::ReadOnlyRecord => e
  #    if respond_to? :deleted?
  #      errors.add :base, '削除済みのため、編集できません。'
  #      return false
  #    end
  #    raise e
  #  end

  def check_deleted
    return unless deleted? && !deleted_at_changed?
    return unless changed? && !(changes.keys.all? { |column| column.in? %w[deleted_at deleter_id] })

    errors.add(:base, '削除済みのため、編集できません。')
  end
end
