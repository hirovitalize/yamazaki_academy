/* global $ */
/* global _ */

$(function () {
  var $form = $('form.simple_form[id*="_student_payment"]');
  if ($form.length > 0) {
    const initial_values = $form.serializeJSON()['student_payment'];

    // 入金種別 中国払いのみ -> 元
    (function () {
      const toggler = function (type) {
        var target = '.form-group.student_payment_gen';
        if (type != '9') { // それ以外
          $(target).clear_cascading();
          $(target).hide();
        }
        else { // 9 中国支付
          $(target).show();
        }
      };

      toggler(initial_values['paymethod_id']);
      $form.find('#student_payment_paymethod_id').change(function () {
        toggler(_.get($form.serializeJSON(), ['student_payment', 'paymethod_id']))
      });
    }());
  }
});
