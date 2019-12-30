# frozen_string_literal: true

module GrapeApi
  module RequestHelper
    extend Grape::API::Helpers

    def authenticate!
      error!('Unauthorized', 401) if current_user.blank?

      # papertrail
      ::PaperTrail.request.enabled = true
      ::PaperTrail.request.whodunnit = current_user.try(:id)

      # userstamp
      User.stamper = current_user
    end

    def current_user
      @current_user ||= find_user
    end

    def find_user
      auth_token = request.headers['X-Access-Token']
      return nil if auth_token.blank?

      User.find_by(auth_token: auth_token)
    end

    def search_scope(model, options)
      activerecord = model.ransack(options[:q])
      activerecord = activerecord.result(distinct: true)
      activerecord = activerecord.group params[:group] if params[:group].present?

      if options[:page].present? || options[:per].present?
        activerecord.page(options[:page]).per(options[:per])
      else
        activerecord.except(:limit, :offset)
      end
    end

    def normalize_symbols(params_symbols)
      return [] if params_symbols.blank?

      fields = params_symbols.dup
      fields = fields.values if fields.is_a? Hash
      fields.map(&:to_sym)
    end

    def to_bool(value)
      ActiveModel::Type::Boolean.new.cast(value)
    end

    def ignore_nonexisted_column(sym, model)
      # 列名でなくて複合クエリであればそのままでOK
      return sym unless sym.to_s =~ /^[a-z_]*$/

      # DBに存在する列なら、そのまま実行OK
      return sym if sym.to_s.in? model.columns.map(&:name)

      "null as `#{sym}`".to_sym
    end
  end
end
