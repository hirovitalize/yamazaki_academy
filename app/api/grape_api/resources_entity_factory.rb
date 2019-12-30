# frozen_string_literal: true

module GrapeApi
  class ResourcesEntityFactory < Grape::Entity
    MAX_ASSOCIATION_NEST_DEPTH = 1

    def self.create(model, association = true, depth = 0)
      clazz_name = "#{model.name.delete(':')}Entity#{'WithAssoc' if association}"
      class_presence?(clazz_name) || generate_class(clazz_name, model, association, depth)
    rescue StandardError => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.slice(0, 20).join(', ')
      ResourcesEntity # Dummy
    end

    class << self
      private

      def class_presence?(class_name)
        klass = Class.const_get(class_name)
        return nil unless klass.is_a?(Class)

        klass
      rescue NameError
        nil
      end

      def generate_class(clazz_name, model, association = true, depth = 0)
        self.class.const_set :"#{clazz_name}", Class.new(Grape::Entity)
        clazz = self.class.const_get(clazz_name)

        model.attribute_types.map do |field, model_type|
          next if field.to_s.in? fields_excluded

          docs = {
            type: model_type_to_json_schema(model_type),
            desc: model.human_attribute_name(field)
          }
          clazz.class_eval do
            expose field, documentation: docs
          end
        end

        if association && depth <= MAX_ASSOCIATION_NEST_DEPTH
          assocs = []
          model.reflect_on_all_associations.each do |assoc|
            next if assoc.name.to_s.in? fields_excluded
            next if assoc.polymorphic?

            rel_clazz = create(
              assoc.klass,
              depth + 1 < MAX_ASSOCIATION_NEST_DEPTH,
              depth + 1
            )
            docs = {
              is_array: assoc.collection?,
              desc: model.human_attribute_name(assoc.name)
            }
            assocs << assoc.name
            clazz.class_eval do
              expose assoc.name, documentation: docs, using: rel_clazz
            end
          end

          clazz_self = clazz.class_eval { class << self; self; end }
          clazz.const_set('ASSOCS', assocs.dup.freeze)
          clazz_self.class_eval do
            def associations
              self::ASSOCS
            end
          end
        end

        clazz
      end

      # PaperTrail, UserStamp回りの関連は関連過剰でSwaggerUIが落ちる
      # -> APIから関連を除外
      # セキュリティ上まずそうなものも出さない
      # 個人情報系も出さない
      # Uncaught RangeError: Invalid string length at JSON.stringify (<anonymous>)
      def fields_excluded
        %w[creator updater deleter versions] +
          %w[encrypted_password password_salt password auth_token reset_password_token] +
          %w[birthday sex tel qq wechat mail email phone]
      end

      # @see model_type: https://github.com/rails/rails/tree/master/activemodel/lib/active_model/type
      # @see json_schema:
      def model_type_to_json_schema(model_type)
        case model_type
        when :text then 'string'
        when :binary then 'string'
        when :datetime then 'date-time'
        else model_type.type
        end
      end
    end
  end
end
