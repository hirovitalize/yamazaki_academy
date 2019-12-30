# frozen_string_literal: true

# 各コントローラーのpolicy作成コマンド
# rails g pundit:policy comment
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # overwrite!
  ROLE_NAMES = [].freeze # allowed
  def with_role?(role_names = nil)
    role_names = self.class::ROLE_NAMES if role_names.nil?
    return true if role_names.blank?
    return false if user.blank?

    role_names.any? { |code| user.role? code }
  end

  alias new? with_role?
  alias create? with_role?
  alias edit? with_role?
  alias update? with_role?
  alias destroy? with_role?

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  def admin?
    user.role_admin?
  end

  def method_missing?(method, *args)
    return true if method.end_with('?')

    super method, *args
  end
end
