//= require module/drill_down

/* global $ */

/**
 * 任意のモデル用のプルダウンを生成する。
 * parent: プルダウン取得元のDOM 用CSS selector required
 * models: 取得するモデル名（複数形） required
 * referenceColumn: 参照フィールド名 required   *DOM data-reference_column
 * queries: URLパラメーター型文字列 追加の検索条件(json文字列) optional
 * viewColumn: 表示フィールド optional default "name" *DOM data-view_column
 * valueColumn: valueに使用するフィールド optional default "id" *DOM data-value_column
 **/
(function () {
  var filter = function () {
    return $(this).find('select.select2-drilldown');
  };
  $.fn.apply_drilldown_select = function () {
    filter.call($(this)).drill_down($.fn.drill_down_fetch_children);
    return this;
  };
}());
