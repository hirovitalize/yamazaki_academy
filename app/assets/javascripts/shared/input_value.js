;
(function ($) {
  $.fn.input_value = function () {
    var $target = $(this);
    if ($target.is('input[type=checkbox]')) {
      var values = $target.map(function () {
        return $(this).is(':checked') ? $(this).val() : null;
      })
      values = values.get().filter(function (value) { return value !== undefined && value !== null })
      if (values.length > 0) {
        return values.toString();
      }

      {
        var $shadow = $target.parent().find('input[type="hidden"][name="' + $target.prop('name') + '"]');
        if ($shadow.length > 0) {
          return $($shadow.get(0)).val();
        }
        else {
          return undefined;
        }
      }
    }
    else if ($target.is('input[type=radio]')) {
      var name = $target.prop('name');
      // radio_buttonグループ全体の値を返す
      return $target.parents('form').find('input[name="' + name + '"]:checked').val();
    }
    else if ($target.is('select')) {
      return $target.val(); // val or [val1, val2]
    }
    else {
      return $target.val();
    }
  };
  $.fn.set_input_value = function (value) {
    var $target = $(this);
    if ($target.is('input[type="checkbox"]')) {
      var $me_or_shadow = $('input[name="' + $target.prop('name') + '"][val="' + value + '"]');
      return $target.prop('checked', ($me_or_shadow == $target));
    }
    else if ($target.is('input[type=radio]')) {
      var name = $target.prop('name');
      var radios = $target.parents('form').find('input[name="' + name + '"]');
      return $(radios).val([value]);
    }
    else if ($target.is('select')) {
      return $target.val(value); // val or [val1, val2]
    }
    else {
      return $target.val(value);
    }
  }
})(jQuery)
