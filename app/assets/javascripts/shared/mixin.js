/* global _ */
/* global $ */

_.mixin({
  queryParams: function (key) {
    var arg = new Object;
    var pair = window.location.search.substring(1).split('&')
    for (var i = 0; pair[i]; i++) {
      var kv = pair[i].split('=')
      arg[kv[0]] = kv[1]
    }
    return arg[key] || arg
  },

  toggleArray: function (array, value) {
    if (_.includes(array, value)) {
      _.pull(array, value)
    } else {
      array.push(value)
    }
    return array
  }
}, { chain: false })

$.fn.extend({
  showLoading: function () {
    $(this).attr('data-widget', 'loading')
  },

  hideLoading: function () {
    $(this).removeAttr('data-widget', 'loading')
  }
})