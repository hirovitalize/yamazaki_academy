/**
 * input用のDate pickerを初期化する
 *
 * 固有のオプションを付与したい場合はHTML側のdata-date-optionsに設定する
 * https://flatpickr.js.org/options/
 */

/* global $ */
/* global _ */

(function () {
  const target = '[data-widget=datepicker]';

  const applyer = function () {
    const $self = $(this);
    const conf = $self.data('dateOptions');
    const defaultConf = {
      locale: 'ja',
      format: 'Y/m/d',
      allowInput: true
    };

    $self.flatpickr($.extend({}, defaultConf, conf));
  };

  const filter = function () {
    return $(this).find(target);
  };

  $.fn.apply_datepicker = function () {
    filter.call($(this)).each(applyer);
    return this;
  };
}());
