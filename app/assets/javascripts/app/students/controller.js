/* global $ */
/* global moment */
/* global flatpickr */

$(function () {
  var $form = $('form.simple_form[id*="_student"]');
  if ($form.length > 0) {
    // 誕生日  起動時初期値
    (function () {
      $('#student_birthday').get(0)._flatpickr.config.onOpen.push(
        function (selectedDates, dateStr, instance) {
          if (!!dateStr) return;

          instance.jumpToDate(moment().subtract(17, 'years').format('YYYY-MM-DD'));
        }
      );
    }());
  }
});
