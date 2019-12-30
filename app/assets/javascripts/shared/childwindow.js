/* global $ */
/* global _ */
/* global store */

/**
 * 子ウィンドウを表示します。
 * ````
 * button data-toggle='childwindow' data-url='/alliance/1/edit' data-name='alliance-edit'
 * = button_tag '', data: {toggle: 'childwindow', url: path, name: 'alliance-edit'}
 * ```
 * nameを指定していれば、同一の子ウィンドウに表示します。
 * なければ、全部新規となります。
 * ブラウザが対応していない場合、別タブで起動されます。
 *
 * 子ウィンドウの各種パラメーターは、data-xxxxx に格納してください。
 *
 * 子ウィンドウからのコールバック、自動リロードなどの設定は、
 * 以下を参照のこと。
 * @see app/assets/javascripts/shared/childwindow_actions.js
 **/
(function () {
  const default_options = {
    menubar: 'no',
    toolbar: 'no',
    location: 'no',
    status: 'no',
    scrollbars: 'yes',
    dependent: 'yes',
    alwaysRaised: 'yes',
    close: 'yes',
    resizable: 'yes',
    /** TODO: 画面サイズなどに応じて サイズor 起動形式を変える in childwindow_action */
    // 設定なし: 小中サイズ
    // 設定あり: ほぼ全体化
    left: 400,
    top: 400,
    height: 600,
    width: 500
  };

  const options_to_param_string = function (options) {
    var str = '';
    _.each(options, function (val, key) {
      str += key.toString() + '=' + val.toString() + ',';
    });
    return str;
  };
  const childWindows = {};

  const apply = function () {
    const self = $(this);
    const options = self.data();
    self.on('click', function (e) {
      e.preventDefault();

      const name = '_childwindow_' + (options.name || options.url);
      const open_config = $.extend({},
        default_options,
        _.pickBy(options, function (value, key) {
          return _.keys(default_options).includes(key);
        })
      );

      const w = window.open(
        options.url,
        name,
        options_to_param_string(open_config)
      );
      if (w == null) {
        return;
      }
      childWindows[name] = w;
      $(w).focus();

      store.removeExpiredKeys();
      store.set(name, options, new Date().getTime() + (86400 * 1000));
    });
  };

  $(function () {
    $(window).on('unload', function () {
      $.each(childWindows, function (_, w) {
        if (w == null) {
          return
        }
        // TODO optionで切り分け。ものによっては、親に関係なくkeepする
        w.close()
      })
    })
  })

  const filter = function () {
    return $(this).find('[data-toggle="childwindow"]')
  }
  $.fn.apply_childwindow = function () {
    filter.call($(this)).each(apply)
    return this
  }
}());
