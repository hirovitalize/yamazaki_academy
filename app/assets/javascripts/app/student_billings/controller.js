/* global $ */
/* global _ */

const ApiClient = require('module/api_client');
const BigNumber = require('bignumber.js');

$(function () {
  var $form = $('form.simple_form[id*="_student_billing"]');
  if ($form.length > 0) {
    const field_total = '#student_billing_total';
    const field_details = function (field) {
      return '.js-detail [id^="student_billing_student_billing_details_attributes_"][id$="_' + field + '"][name$="[' + field + ']"]';
    };
    const field_discounts = function (field) {
      return '.js-discount [id^="student_billing_student_billing_details_attributes_"][id$="_student_billing_detail_discount_attributes_' + field + '"][name$="[' + field + ']"]';
    };
    const $area_details = $form.find('.cocoon-append-target');

    // 額・discount変更時
    (function () {
      const recalc_total = function () {
        const details = _.get($form.serializeJSON(), ['student_billing', 'student_billing_details_attributes']);
        const sum_price = _.sum(_.map(details, function (v) {
          if (v['_destroy'] != 'false') return 0;
          const value = Number(v['price']) - Number(_.get(v, ['student_billing_detail_discount_attributes', 'price'], 0));
          return value < 0 ? 0 : value;
        }));

        const $target = $form.nearest(field_total);
        if (Number($target.val()) != Number(sum_price)) {
          $target.val(Number(sum_price));
        }
      };

      const listen_by_detail = function ($dom) {
        $dom.find(field_details('price') + ', ' + field_discounts('price')).change(function () {
          recalc_total();
        });

        // 項目 -> 額
        $dom.find(field_details('item_id')).change(function () {
          const type = $(this).nearest(field_details('item_type')).val();

          if (type == 'Course') {
            const id = $(this).val();
            const course = !id ? null : ApiClient.fetch_one('courses', id);
            const price = !course ? 0 : course['price'];
            $(this).nearest(field_details('price')).val(price).trigger('change');
          }
          else if (type == 'Book') {
            const id = $(this).val();
            const book = !id ? null : ApiClient.fetch_one('books', id);
            const price = !book ? 0 : book['price'];
            $(this).nearest(field_details('unit_price')).val(price).trigger('change');
          }
        });

        // 単価・個数 -> 額
        $dom.find(field_details('unit_price') + ', ' + field_details('number')).change(function () {
          // 項目(Vip) -> 単価
          const type = $(this).nearest(field_details('item_type')).val();
          if (type == 'Vip' && $(this).is(field_details('number'))) {
            const prices = ApiClient.fetch('vip_prices', { unit: $(this).val() });
            const price = !prices ? 0 : prices['0']['unit_price'];
            const $target = $(this).nearest(field_details('unit_price'));
            if ($target.val() != price) {
              $target.val(price).trigger('change');
              return;
            }
          }


          if ($(this).is(':hidden')) return;
          const unit_price = $(this).nearest(field_details('unit_price')).val();
          const number = $(this).nearest(field_details('number')).val();
          const price = BigNumber(unit_price).times(number).integerValue(BigNumber.ROUND_FLOOR);
          const $target = $(this).nearest(field_details('price'));
          if (Number($target.val()) != Number(price)) {
            $target.val(Number(price)).trigger('change');
          }
        });

        // 値引種別 -> 値引額
        $dom.find(field_discounts('discount_type_id') + ', ' + field_details('price')).change(function () {
          const $target = $(this).nearest(field_discounts('price'));
          const id = $(this).nearest(field_discounts('discount_type_id')).val();
          const discount = !id ? null : ApiClient.fetch_one('discount_types', id);

          var price;
          if (!discount) {
            price = 0;
          }
          else if (!!discount['price']) {
            price = discount['price'];
          }
          else if (!!discount['rate']) {
            price = BigNumber($(this).nearest(field_details('price')).val()).times(BigNumber(0.01).times(discount['rate'])).integerValue(BigNumber.ROUND_FLOOR);
          }
          else {
            $target.val(0).attr('readonly', false).trigger('change');
            return;
          }

          if (Number($target.val()) != Number(price)) {
            $target.val(Number(price)).attr('readonly', true).trigger('change');
          }
        });
      };

      listen_by_detail($form); //画面起動時
      $area_details.on('cocoon:after-insert', function (evt, dom) {
        listen_by_detail($(dom));
        $(dom).find(field_details('number')).trigger('change');
      }); // 追加時

      $area_details.on('cocoon:after-remove', function (evt, dom) {
        recalc_total();
      });
    }());
  }
});
