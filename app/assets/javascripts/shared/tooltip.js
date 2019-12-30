/**
 * Tool tipを初期化する
 */

/* global $ */

(function () {
  const target = '[data-toggle=tooltip]';

  const applyer = function () {
    $(this).tooltip();
  };

  const filter = function () {
    return $(this).find(target);
  };

  $.fn.apply_tooltip = function () {
    filter.call($(this)).each(applyer);
    return this;
  };
}());
