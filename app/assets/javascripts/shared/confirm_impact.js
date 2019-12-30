//= require shared/input_value

/* global jQuery */
/* global _ */
/* global toastr */

;
(function ($) {
  var defaults = {
    name: "?",
    selector: "?",
    clear: function ($target) { $target.clear_cascading(); },
    condition: function ($value) { return true; },
    then: function () { return true; /** do nothing; **/ },
    popup: true
  };

  var normalize_selector = function (value) {
    if (typeof value === 'function') return value;
    if (typeof value === 'string') return function () { return $(value) };
    throw new TypeError('function か string(CSS selector) で指定してください！');
  }

  /**
   * @params targets (array)
   *   [{
   *      name: '表示名',
   *      selector: 'dom_selector',
   *      clear: 'clear方法。default: $(target).clear_cascading()',
   *      then: function(new_value) '追加の処理'
   *      popup: true/false toastr表示の有無 (default: true)
   *   }]
   * @param confirm = false '確認の上でキャンセルが可能', default: false,
   **/
  $.fn.confirm_impact = function (options, cancel) {
    if (cancel === undefined) cancel = false;
    if (!Array.isArray(options)) {
      options = [options];
    }
    if (options.length == 0) return this;
    var _options = _.map(options, function (option) { return _.merge({}, defaults, option); });

    var prev_val;
    $(this).focusin(function () {
      var val = $(this).input_value();
      if (val !== undefined) prev_val = val;
    }).click(function () {
      var val = $(this).input_value();
      if (val !== undefined) prev_val = val;
    });

    $(this).change(function () {
      var $source = $(this);
      var names = [];
      _.each(_options, function (option) {
        if (!option['popup']) return;
        names.push(option['name']);
      });

      var progress;
      if (cancel) {
        progress = window.confirm("以下の項目を初期化します。よろしいですか?\n" + names.join("\n"));
      }
      else {
        progress = true;
        if (names.length) {
          toastr.info("以下の項目を初期化しました。<br/>" + names.join("<br/>"));
        }
      }
      if (progress) {
        _.each(_options, function (option) {
          var input_value = $source.input_value();
          var condition = option['condition'];
          if (!condition(input_value)) return;

          var clear = option['clear'];
          var selector = normalize_selector(option['selector']);
          clear(selector(input_value));

          var then = option['then'];
          then(input_value);
        });
      }
      else {
        $source.set_input_value(prev_val);
      }

      return progress;
    });
    return this;
  };
})(jQuery);
