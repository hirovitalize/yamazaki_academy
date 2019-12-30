//= require shared/clear_cascading
//= require shared/confirm_impact
//= require shared/input_value

/**
 * jquery拡張。
 * dom操作系の便利メソッドがあればここに生やします。
 **/

/* global jQuery */
/* global _ */
/* global swal */
(function ($) {
  /** 一つずつ親に上りながら、マッチするノードを探す **/
  $.fn.nearest = function (selector) {
    if (this.length == 0) return $();
    var $parent = this;
    while (1) {
      var $found = $parent.find(selector);
      if ($found.length > 0) {
        return $found;
      }
      $parent = $parent.parent();
      if ($parent.length == 0) {
        break;
      }
    }
    return $(selector);
  };

  /**
   * @params targets (array)
   *   {
   *      validator: function '押下可能な条件' NG時はその理由(string)を返す
   *   }
   *   this: 押下可否をチェックする対象
   **/
  $.fn.alert_validate = function (validator) {
    $(this).click(function (evt) {
      var cause = validator();
      if (cause !== undefined && cause.toString().length > 0) {
        swal({
          text: '以下の理由により、操作できません。' + "\n" + cause.toString(),
          icon: 'warning'
        });

        evt.preventDefault();
        evt.stopImmediatePropagation();
        return false;
      }
      return true;
    });
    return this;
  };

  $.fn.form_toggle = function (show) {
    $(this).toggle(show);
    $(this).find('input, select, textarea').prop('disabled', !show);
  };
}(jQuery))
