/* global $ */

module.exports = {
  createHiddenTags: function (name, value) {
    return $('<input>')
      .attr('type', 'hidden')
      .attr('name', name)
      .attr('value', value)
  },

  createOptionTags: function (list, valueKey = 'id', textKey = 'name') {
    let options = []
    options.push('<option value=""></option>')
    $.each(list, function (k, v) {
      options.push('<option value="' + v[valueKey] + '">' + v[textKey] + '</option>')
    })
    return options
  }
}
