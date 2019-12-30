/**
 * input用のDate time pickerを初期化する
 *
 * 固有のオプションを付与したい場合はHTML側のdata-date-optionsに設定する
 * https://flatpickr.js.org/options/
 */

/* global $ */


(function () {
  const target = '[data-widget=datetimepicker]';

  const applyer = function () {
    const $self = $(this);
    const conf = $self.data('dateOptions');
    const defaultConf = {
      locale: 'ja',
      enableTime: true,
      defaultHour: 9,
      dateFormat: 'Y/m/d H:i',
      time_24hr: true,
      allowInput: true
    };

    $self.flatpickr($.extend({}, defaultConf, conf));
  };

  const filter = function () {
    return $(this).find(target);
  };

  $.fn.apply_datetimepicker = function () {
    filter.call($(this)).each(applyer);
    return this;
  };
}());
