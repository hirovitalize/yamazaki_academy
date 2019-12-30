/**
 * 郵便番号検索フォームを初期化する
 *
 *
 * HTML側の設定は下記の通り
   ==================================================
    input_html: {
      data: {
        widget: 'postcode',
        'postcode-pref': '都道府県フォームのセレクタ',
        'postcode-address': '住所フォームのセレクタ'
      }
    }
   ==================================================
 */

/* global $ */
/* global YubinBango */
/* global Cleave */

(function () {
  const target = '[data-widget=postcode]';

  const applyer = function () {
    new Cleave(this, {
      numericOnly: true,
      blocks: [7]
    });

    const $self = $(this);
    const targetPref = $($self.data('postcodePref'));
    const targetAddress = $($self.data('postcodeAddress'));

    $self.on('change', function () {
      new YubinBango.Core($self.val(), function (addr) {
        targetPref.val(addr.region_id).trigger('change');
        targetAddress.val(`${addr.locality}${addr.street}`);
      });
    });
  };

  const filter = function () {
    return $(this).find(target);
  };

  $.fn.apply_postcode = function () {
    filter.call($(this)).each(applyer);
    return this;
  };
}());
