/**
 * Ajaxのラッパーメソッド
 */

/* global $ */

const AjaxConstants = require('module/ajax_constants')
const pluralize = require('pluralize')

module.exports = {
  common_columns: ['id', 'created_at', 'updated_at', 'deleted_at', 'lock_version'],
  fetch_one_params: function (models, id, ajax_options = {}, api_options = {}) {
    return $.extend({}, AjaxConstants.optionDefaults, {
      type: 'GET',
      url: '/api/v1/' + models + '/' + id + '.json',
      async: false,
      dataType: 'json',
      data: api_options
    }, ajax_options);
  },
  fetch_params: function (models, params, ajax_options = {}, api_options = {}) {
    return $.extend({}, AjaxConstants.optionDefaults, {
        type: 'GET',
        url: '/api/v1/' + models + '.json',
        async: false,
        dataType: 'json',
        data: $.extend({}, {
          q: params
        }, api_options)
      },
      ajax_options);
  },
  create_params: function (models, params, ajax_options = {}, api_options = {}) {
    return $.extend({}, AjaxConstants.optionDefaults, {
        type: 'POST',
        url: '/api/v1/' + models + '.json',
        async: false,
        dataType: 'json',
        data: $.extend({}, {
        [pluralize.singular(models)]: params
        }, api_options)
      },
      ajax_options);
  },
  update_params: function (models, id, params, ajax_options = {}, api_options = {}) {
    return $.extend({}, AjaxConstants.optionDefaults, {
      type: 'PUT',
      url: '/api/v1/' + models + '/' + id + '.json',
      async: false,
      dataType: 'json',
      data: $.extend({}, {
        [pluralize.singular(models)]: params
      }, api_options)
    }, ajax_options);
  },
  fetch_one: function (models, id, ajax_options = {}, api_options = {}) {
    return JSON.parse($.ajax(this.fetch_one_params(models, id, ajax_options, api_options)).fail(AjaxConstants.fail).responseText);
  },
  fetch: function (models, params, ajax_options = {}, api_options = {}) {
    return JSON.parse($.ajax(this.fetch_params(models, params, ajax_options, api_options)).fail(AjaxConstants.fail).responseText);
  },
  update: function (models, id, params, ajax_options = {}, api_options = {}) {
    return $.ajax(this.update_params(models, id, params, ajax_options, api_options)).fail(AjaxConstants.fail);
  },
  create: function (models, params, ajax_options = {}, api_options = {}) {
    return $.ajax(this.create_params(models, params, ajax_options, api_options)).fail(AjaxConstants.fail);
  }
}
