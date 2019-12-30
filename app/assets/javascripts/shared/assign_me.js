/* global $ */
/* global _ */
const AjaxConstants = require('module/ajax_constants');

/**
 * @see /app/views/shared/action/_mine_button.html.slim
 **/
(function () {
  const fetcher = function (id, models) {
    return $.ajax($.extend({}, AjaxConstants.optionDefaults, {
      type: 'GET',
      async: false,
      url: '/api/v1/' + models + '.json',
      data: { q: { id_eq: id }, select: ['name', 'id'] },
      dataType: 'candidates',
      converters: {
        'json candidates': function (data) {
          return [{ id: '', text: '' }].concat(_.map(data, function (child) {
            return {
              id: child['id'],
              text: child['name']
            };
          }));
        }
      }
    })).fail(AjaxConstants.fail).promise();
  };

  const select_changer = function ($target, selector) {
    $target.find(selector).prop('selected', true);
    $target.trigger('change.select2'); //多重にcascadeしないように、select2の更新のみ。
  };

  const runner = function (id, models) {
    const $target = $(this);

    if ($target.is('select')) {
      const selector = 'option[value="' + id + '"]';
      if ($target.has(selector).length == 0) {
        fetcher(id, models).then(function (candidates) {
          $target.select2({ data: candidates });
          select_changer($target, selector);
        });
      }
      else {
        select_changer($target, selector);
      }
    }
    else {
      $target.val(id);
    }
  };

  const applyer = function () {
    const $self = $(this);
    $self.on('click', function () {
      const config = $self.data();
      if (config['user'] && config['userTarget']) {
        runner.call($self.nearest(config['userTarget']), config['user'], 'users');
      }
      if (config['staff'] && config['staffTarget']) {
        runner.call($self.nearest(config['staffTarget']), config['staff'], 'staffs');
      }
    });
  };
  const filter = function () {
    return $(this).find('[data-toggle="assign_me"]');
  };
  $.fn.apply_assign_me = function () {
    filter.call($(this)).each(applyer);
    return this;
  };
}());
