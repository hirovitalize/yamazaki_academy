/**
 * input用のカラーピッカーを初期化する
 *
 * http://bgrins.github.io/spectrum/#options
 */

/* global $ */

(function () {
  const target = '[data-widget=colorpicker]';

  const applyer = function () {
    const $self = $(this);
    $self.spectrum({
      preferredFormat: 'hex',
      allowEmpty: true,
      chooseText: '選択する',
      cancelText: 'キャンセル'
    });
  };

  const filter = function () {
    return $(this).find(target);
  };

  $.fn.apply_colorpicker = function () {
    filter.call($(this)).each(applyer);
    return this;
  };
}());
