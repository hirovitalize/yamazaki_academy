/* global $ */
/* global _ */

/**
 * @see /app/views/shared/action/_select_all_button.html.slim
 **/
(function () {
  const runner = function () {
    const $target = $(this);

    if ($target.is('select')) {
      if (!$.isEmptyObject($target.val())) {
        // 全解除
        $target.val([]).trigger('change');
      }
      else {
        // 全選択
        $target.val(_.compact(_.map($target.find('option').get(), function (opt) { return $(opt).val(); }))).trigger('change');
      }
    }
    else {
      // TODO checkbox
    }
  };

  const applyer = function () {
    const $self = $(this);
    $self.on('click', function () {
      const config = $self.data();
      if (config['target']) {
        runner.call($self.nearest(config['target']));
      }
    });
  };
  const filter = function () {
    return $(this).find('[data-toggle="select_unselect_all"]');
  };
  $.fn.apply_select_all = function () {
    filter.call($(this)).each(applyer);
    return this;
  };
}());
