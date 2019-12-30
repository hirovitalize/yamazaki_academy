/* global $ */
/* global _ */

const ApiClient = require('module/api_client');

/**
 * 任意のモデル用のプルダウン(ajax-autocomplete)を生成する。
 * models: 取得するモデル名（複数形） required
 * mainQuery: ransack_query名 optional default: 'name_cont'
 * queries: URLパラメーター型文字列 追加の検索条件(json文字列) optional
 * viewColumn: 表示フィールド optional default "name" *DOM data-view_column
 * valueColumn: valueに使用するフィールド optional default "id" *DOM data-value_column
 **/
(function () {
  const applyer = function () {
    const $self = $(this);
    const config = $self.data();
    const view_column = config['viewColumn'] || 'name';
    const value_column = config['valueColumn'] || 'id';
    const placeholder = config['placeholder'] || "名称を入力（2文字以上）";
    const minimumInputLength = config['minimumInputLength'] || 2;
    const per = config['limit'] || 100
    const order = config['sort'] || 'id desc'

    const query_func = function (params) {
      const key = mainquery(config)
      const queries = { s: order };
      queries[key] = params.term;
      if (config['queries'] != undefined) {
        queries = $.extend({}, queries, config['queries'])
      }
      return {
        q: queries,
        per: per,
        select: _.union([view_column, value_column], ApiClient.common_columns)
      };
    };
    $self.select2({
      placeholder: placeholder,
      language: "ja",
      minimumInputLength: minimumInputLength,
      allowClear: true,
      ajax: ApiClient.fetch_params(config['models'], {}, {
        delay: 750,
        data: query_func,
        processResults: function (data, params) {
          return {
            results: $.merge([{ id: '', text: '' }], $.map(data, function (obj) {
              return build_candidate(obj, config);
            }))
          };
        }
      })
    });
  };

  const mainquery = function (config) {
    const key = config['mainquery'];
    if (!!key) return key;
    return 'name_cont'; // defaults
  }

  const filter = function () {
    return $(this).find('select.select2-autocomplete');
  };

  $.fn.apply_autocomplete_select = function () {
    filter.call($(this)).each(applyer);
    return this;
  }

  const norm_column = function (column) {
    return column.replace(/^.*\./, '')
  }

  const build_candidate = function (obj, config) {
    const view_column = config['viewColumn'] || 'name';
    const value_column = config['valueColumn'] || 'id';
    const text_without_value = config['textWithoutValue'] || true;
    const view = obj[norm_column(view_column)];
    const value = obj[norm_column(value_column)];

    const is_deleted = !!obj[norm_column('deleted_at')];

    return {
      id: obj[norm_column(value_column)],
      text:
        (is_deleted ? '[削除]' : '') +
        (text_without_value ? '' : (value + ' : ')) +
        view
    };
  };
}());
