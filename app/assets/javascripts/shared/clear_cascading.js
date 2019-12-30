/* global jQuery */

;
(function ($) {
  const class_keep = '.' + 'keep_on_cascading'

  /**
   * 配下の入力系DOMをすべてクリアする
   * ※　クリアしたくないDOMには、class "keep_on_cascading"をつける
   **/
  $.fn.clear_cascading = function () {
    // 本PRJ特有。cocoonの子データを削除
    $(this)
      .find('.js-children-delete')
      .not(class_keep)
      .trigger('click');

    $(this)
      .find(':input')
      .not(':button, :submit, :reset, :hidden, :radio, :checkbox')
      .not(class_keep)
      .each(function () {
        var prev_val = $(this).val();
        $(this).val('');
        var current_val = $(this).val();
        if (prev_val === current_val) return;
        $(this).trigger('change');
      });

    $(this)
      .find(':radio, :checkbox')
      .not(class_keep)
      .each(function () {
        var prev_checked = $(this).prop('checked');
        $(this).prop('checked', false);
        if (prev_checked === false) return;
        $(this).trigger('change');
      });

    $(this)
      .find('select')
      .each(function () {
        var value_changed = false;
        $(this)
          .find('option')
          .not(class_keep)
          .each(function () {
            var prev_checked = $(this).prop('selected');
            $(this).prop('selected', false);
            if (prev_checked === false) return;
            value_changed = true;
          });
        if (value_changed) {
          $(this).trigger('change');
        }
      });

    return $(this);
  };
})(jQuery);
