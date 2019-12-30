# frozen_string_literal: true

module ActionView
  module RansackHelper
    def ransack_enum_collection(model, field)
      name_sym = model.send("#{field.to_s.pluralize}_i18n").invert

      # integerの場合、ransackが適切に変換しない（実行時に0となる　→　symbol使わずに元の値を使う)
      # @see http://b.hatena.ne.jp/entry/www.tom08.net/entry/2016/12/05/121746 昔はstringもbooleanもダメだったみたいね。
      if model.send(field.to_s.pluralize.to_s).values.first.instance_of? Integer
        return name_sym.map { |name, sym| [name, model.send(field.to_s.pluralize.to_s).fetch(sym)] }
      end

      name_sym.to_a # 通常時
    end
  end
end
