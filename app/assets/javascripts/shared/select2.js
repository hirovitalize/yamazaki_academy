/**
 * Select2 を初期化する
 */

/* global $ */

const Select2 = require('module/select2_init');

(function () {
  const target = '[data-widget="select2"]';

  const applyer = function () {
    new Select2(this);
  };

  const filter = function () {
    return $(this).find(target);
  };

  $.fn.apply_select2 = function () {
    filter.call($(this)).each(applyer);
    return this;
  };
}());
