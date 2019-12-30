/* global jQuery */
/* global _ */

const AjaxConstants = require('module/ajax_constants');
const ApiClient = require('module/api_client');

(function ($) {
  let default_config = function () {
    return {
      runempty: false,
      appendOnly: false,
      selectAutoFirst: false,
      selectIfSingle: true,
      viewColumn: 'name',
      valueColumn: 'id',
      per: 500,
      textWithoutValue: true,
      mainquery: false
      // parent: required
      // models: required
      // referenceColumn: required
      // queries: undefined,
    }
  };

  $.fn.drill_down = function (fetcher) {
    $(this).each(function (i, dom) {
      var $me = $(dom);
      var config = $.extend({}, default_config(), $me.data());
      var runner = function () {
        var $parent = $(this);
        var selected = $me.val();

        if (!$parent) return;
        var parent_ids = $parent.val();
        //if (!parent_ids) return;
        fetcher(parent_ids, config).then(function (candidates) {
          apply_candidates($me, candidates, selected, config);
        });
      };

      var $parent = $me.nearest(config['parent']);
      $parent.on('change', runner);
      runner.apply($parent);
    });
    return this;
  };

  /**
   * 任意のモデル用のプルダウンを生成する。
   * parent: プルダウン取得元のDOM 用CSS selector required
   * models: 取得するモデル名（複数形） required
   * referenceColumn: 参照フィールド名 required   *DOM data-reference_column
   * queries: URLパラメーター型文字列 追加の検索条件(json文字列) optional
   * viewColumn: 表示フィールド optional default "name" *DOM data-view_column
   * valueColumn: valueに使用するフィールド optional default "id" *DOM data-value_column
   * runempty: parentが空でもajaxを実行する
   * selectAutoFirst: プルダウンの最上段を自動で選択状態にする *DOM data-select_auto_first
   * selectIfSingle: 結果が単数だった場合、プルダウンの最上段を自動で選択状態にする *DOM data-select_if_single
   **/
  $.fn.drill_down_fetch_children = function (parent_ids, config) {
    if ((!!parent_ids && parent_ids.length == 0) && !config['runempty']) {
      return new Promise(function (resolve, reject) {
        resolve([]);
      });
    }

    var query = {};
    var mainquery = config['mainquery'] || (config['referenceColumn'] + '_in');
    query[mainquery] = parent_ids;
    if (config['queries'] != undefined) {
      query = $.extend({}, query, config['queries']);
    }
    return $(this).drill_down_fetcher_simple(query, config);
  };

  var selectFirstIfEmpty = function ($me) {
    var selected = $me.val();
    if (selected === undefined || !selected) {
      var founds = _.compact($me.find('option').map(function (i, dom) { return $(this).val(); }));
      if (founds) $me.val(founds[0]);
    }
    if (selected != $me.val()) {
      $me.trigger('change');
    }
  };

  /**
   * drill_down の簡易版
   * 複数のパラメータを元にプルダウンを生成したい場合に使用する
   **/
  $.fn.drill_down_simple = function (queries, config) {
    var $me = $(this);
    if ($me.length == 0) return this;
    var selected = $me.val();
    $me.drill_down_fetcher_simple(queries, config).then(function (candidates) {
      apply_candidates($me, candidates, selected, config);
    });
    return this;
  };

  const apply_candidates = function ($me, candidates, selected, config) {
    if (!!config['appendOnly']) {
      $me.select2({ data: candidates });
    }
    else {
      // 入れ替え
      $me.empty().select2({ data: $.merge([{ id: '', text: '' }], candidates) }).val(selected);
      if (!!config['selectAutoFirst'] ||
        (!!config['selectIfSingle'] && candidates.length == 1)
      ) {
        selectFirstIfEmpty($me);
      }
      $me.trigger('change.select2'); // 表示更新。cuscadeはさせない
    }
  };

  $.fn.drill_down_fetcher_simple = function (queries, config) {
    const params = ApiClient.fetch_params(config['models'], {}, {
      async: true,
      data: {
        q: queries,
        select: _.union([config['viewColumn'], config['valueColumn']], ApiClient.common_columns),
        per: config['per']
      },
      dataType: 'candidates',
      converters: {
        'json candidates': function (data) {
          return _.map(data, function (child) {
            return build_candidate(child, config);
          });
        }
      }
    });
    return $.ajax(params).fail(AjaxConstants.fail).promise();
  };

  var build_candidate = function (obj, config) {
    const view = obj[config['viewColumn']];
    const value = obj[config['valueColumn']];
    const is_deleted = !!obj['deleted_at'];

    return {
      id: value,
      text:
        (is_deleted ? '[削除]' : '') +
        (config['textWithoutValue'] ? '' : (value + ' : ')) +
        view
    };
  };
})(jQuery);
