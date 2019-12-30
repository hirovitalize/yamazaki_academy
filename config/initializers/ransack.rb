module Arel
  module Predications
    def eq_or_null(other)
      eq(other).or(eq(nil))
    end

    def not_eq_or_null(other)
      not_eq(other).or(eq(nil))
    end

    def gteq_or_null(other)
      gteq(other).or(eq(nil))
    end

    def lt_or_null(other)
      lt(other).or(eq(nil))
    end

    def in_or_null(other)
      self.in(other).or(eq(nil))
    end
  end
end

# 全scopeを使用OK
module Ransack
  class Context
    def ransackable_scope?(str, klass)
      klass.respond_to? str
    end

    def chain_scope(scope, args)
      return unless @klass.method(scope) && args != false
      # !!! Monkey Patch!!!!
      # Sanitize-offなので argsを見ない
      # @object = if scope_arity(scope) < 1 && args == true
      @object = if scope_arity(scope) < 1
                  @object.public_send(scope)
                else
                  @object.public_send(scope, *args)
                end
    end

  end
end

Ransack.configure do |config|
  config.ignore_unknown_conditions = !Rails.env.production? # 開発環境では raiseする
  config.sanitize_custom_scope_booleans = false

  # tokenize検索 (AND/OR)
  config.add_predicate 'conts_all',
         arel_predicate: 'matches_all',
         formatter: ->(v){ v.split(/[\p{blank}\p{cntrl}\p{punct}\s、・]+/).compact.map {|s| "%#{Ransack::Constants.escape_wildcards(s)}%" } },
         type: :string,
         compounds: false
  config.add_predicate 'conts_any',
         arel_predicate: 'matches_any',
         formatter: ->(v){ v.split(/[\p{blank}\p{cntrl}\p{punct}\s、・]+/).compact.map {|s| "%#{Ransack::Constants.escape_wildcards(s)}%" } },
         type: :string,
         compounds: false
  config.add_predicate 'eq_any',
         arel_predicate: 'in',
         formatter: ->(v){ v.split(/[\p{blank}\p{cntrl}\p{punct}\s、・]+/).compact },
         type: :string,
         compounds: false

  # 年齢検索
  config.add_predicate 'as_age_lteq',
    arel_predicate: 'gteq',
    formatter: -> (v) { ((v + 1).years.ago + 1.day).to_date },
    type: :integer,
    compounds: false
  config.add_predicate 'as_age_gteq',
    arel_predicate: 'lteq',
    formatter: -> (v) { v.years.ago.to_date },
    type: :integer,
    compounds: false

  # nil込み検索
  config.add_predicate 'eq_or_null', arel_predicate: 'eq_or_null'
  config.add_predicate 'not_eq_or_null', arel_predicate: 'not_eq_or_null'
  config.add_predicate 'gteq_or_null', arel_predicate: 'gteq_or_null'
  config.add_predicate 'lt_or_null', arel_predicate: 'lt_or_null'
  config.add_predicate 'in_or_null', arel_predicate: 'in_or_null', wants_array: true
end