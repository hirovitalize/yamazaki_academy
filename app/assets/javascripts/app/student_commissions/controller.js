/* global $ */

$(function () {
  var $form = $('form.simple_form[id*="_student_commission"]');
  if ($form.length > 0) {
    const initial_values = $form.serializeJSON()['student_commission'];

    // 紹介種別
    (function () {
      const toggler = function (type) {
        var target;

        target = '.form-group.student_commission_referral';
        if (type != 'referral_person') {
          $(target).clear_cascading();
          $(target).hide();
        }
        else {
          $(target).show();
        }

        target = '.form-group.student_commission_cache_back_type';
        if (type != 'cache_back') {
          $(target).clear_cascading();
          $(target).hide();
        }
        else {
          $(target).show();
        }

        target = '.form-group.student_commission_inflow_source';
        if (type != 'referral_inflow') {
          $(target).clear_cascading();
          $(target).hide();
        }
        else {
          $(target).show();
        }
      };

      toggler(initial_values['commission_type']);
      $form.find('fieldset.student_commission_commission_type').change(function () {
        const type = $form.serializeJSON()['student_commission']['commission_type'];
        toggler(type);
      });
    }());
  }
});
