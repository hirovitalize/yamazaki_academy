# frozen_string_literal: true

module ActionView
  module WidgetHelper
    def simple_form_display_defaults(defaults = {})
      base_defaults = {
        wrapper: :horizontal_display,
        as: :display,
        required: false
      }
      base_defaults.merge(defaults)
    end

    def truncated_text(long_text, short_text = nil)
      short_text ||= long_text.to_s.try(:truncate, 30)
      tooltip(long_text) do
        strip_tags(short_text.to_s)
      end
    end

    def tooltip(long_text, options = {})
      content_tag(:a, '', title: long_text, tabindex: '', data: {
        toggle: 'tooltip',
        html: true
      }.merge(options)) do
        yield
      end
    end

    def with_ruby(name, ruby)
      content_tag(:ruby) do
        concat name
        concat content_tag(:rt, ruby)
      end
    end

    # 子ウィンドウ(タブ) アンカー
    # 例
    # = link_child alliances_path, 'アライアンス検索'
    def link_child(url, name = '', options = {})
      html_options = {
        # href: url,
        # target: '_blank'
        data: {
          toggle: 'childwindow',
          url: url
        },
        href: url,
        target: '_blank'
      }.deep_merge(options)

      return content_tag(:a, name, html_options) { yield } if block_given?

      content_tag(:a, name, html_options) do
        # rubocop:disable Rails/OutputSafety
        ApplicationController.helpers.fa_icon('external-link', class: 'fa-fw').html_safe + name
        # rubocop:enable Rails/OutputSafety
      end
    end

    # 子ウィンドウ(タブ)URLを自動生成
    # = link_object model.customer # 標準
    # = link_object model.customer, format: :created_at # シンボルでフィールド名/メソッド名
    # = link_object model.customer, format: 'age' # 文字列でフィールド名/メソッド名 (ここでは生年月日から年齢を計算)
    # = link_object model.customer, format: '固定文字列' # ただの文字列表示
    # = link_object model.customer, format: lambda {|c| "[#{c.name} 作業場所:#{c.customer_workplaces.size}件]"} # Proc.newなどcallableならいろいろ変換実施
    def link_object(object, options = {})
      return if object.blank?

      formatter = options.delete(:format)
      action = options.delete(:action)

      url = RoutingUtil.instance.link(object, action)
      return name(object, formatter) if url.blank?

      link_child(url, name(object, formatter), options)
    end

    # 子画面起動可能な、リンクを生成する
    #
    # 単独実行(カンマ区切り)
    # = link_objects tickets, format: :name
    #
    # 書式調整しながら出力
    # 例:
    # - link_objects tickets do |link|
    #   =<> link
    #   br
    def link_objects(objects, options = {})
      values = objects.compact.map { |object| link_object(object, options) }

      contents = if block_given?
                   (values.map { |v| yield(v) }).join('')
                 else
                   values.join(',&nbsp;')
                 end

      # rubocop:disable Rails/OutputSafety
      contents.html_safe
      # rubocop:enable Rails/OutputSafety
    end

    private

    # 表示名を解釈します
    # formatがあれば、その値に応じて変換を試みます。
    # 例:
    #    format: :created_at  # created_atの結果を文字列表示
    #    format: 'updated_at' # updated_atの結果を文字列表示
    #    format: '固定文字列' # '固定文字列'を表示
    #    format: lambda {|obj| "[#{c.id} #{c.name}]" # lambdaにobjを私て表示
    # なければ、SimpleFormの設定に準じて、field/methodを探索します
    # 独自の表示名を設定したい場合は、
    # モデルに to_labelを実装してください
    def name(object, formatter = nil)
      return nil if object.blank?

      return object.send(formatter) if formatter.is_a?(Symbol) && object.respond_to?(formatter)
      return object.send(formatter) if formatter.is_a?(String) && object.respond_to?(formatter)
      return formatter.call(object) if formatter.is_a? Proc
      return formatter if formatter.is_a?(String)

      field = SimpleForm.collection_label_methods.find { |m| object.respond_to?(m) }
      return nil if field.blank?

      object.send(field)
    end
  end
end
