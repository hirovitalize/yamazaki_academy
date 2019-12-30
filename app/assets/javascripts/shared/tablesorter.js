/**
 * Table sorterを初期化する
 */

/* global $ */

(function () {
  const target = 'table.table-filterable';

  const applyer = function () {
    const $self = $(this);
    $self.tablesorter({
        theme: 'dropbox',
        widthFixed: false,
        widgets: ['filter', 'resizable', 'scroller'],
      })
      .wrap('<div class="table-responsive"></div>');
  };

  const filter = function () {
    return $(this).find(target);
  };

  $.fn.apply_tablesorter = function () {
    filter.call($(this)).each(applyer);
    return this;
  };
}());
