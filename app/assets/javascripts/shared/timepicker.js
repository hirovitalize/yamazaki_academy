/**
 * input用のDate time pickerを初期化する
 *
 * 固有のオプションを付与したい場合はHTML側のdata-date-optionsに設定する
 * https://flatpickr.js.org/options/
 */

/* global $ */

(function () {
  const target = '[data-widget=timepicker]';

  const applyer = function () {
    const $self = $(this);
    const conf = $self.data('dateOptions');
    const defaultConf = {
      locale: 'ja',
      enableTime: true,
      noCalendar: true,
      dateFormat: "H:i",
      time_24hr: true,
      allowInput: true
    };
    $self.flatpickr($.extend({}, defaultConf, conf));
  };

  var filter = function () {
    return $(this).find(target);
  };

  $.fn.apply_timepicker = function () {
    filter.call($(this)).each(applyer);
    return this;
  };
}());
