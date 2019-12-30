/* global $ */
/* global store */

/**
 * 子ウィンドウ上の画面での操作をコントロールします。
 * 全画面に対して、「子ウィンドウで起動しているかどうか」を判定し、アクションを付与します
 * 設定は、子画面起動時に起動元から dataパラメーターに格納してください
 * @see /app/assets/javascripts/shared/childwindow.js
 *  ESC: 画面終了
 *  画面終了時に、親画面をリロード data[reloadParentOnClose] : true
 *  画面終了時に、コールバック実行 data[callbackOnClose]: <javascript>
 *
 * 例: a[data-toggle="childwindow" data-reload_parent_on_close="yes"
 *             data-callback_on_close="document.defaultView.opener.location.reload();"
 **/
(function () {
  const esc_closer = function (evt) {
    const win = this;
    let is_escape = false;
    if ('key' in evt) {
      is_escape = (evt.key == 'Escape' || evt.key == 'Esc');
    }
    else {
      is_escape = (evt.keyCode == 27);
    }
    if (is_escape) {
      if (!win.closed) {
        win.close();
      }
    }
  };

  const parent_reloader = function () {
    const win = this;
    if (!win.closed) {
      return true;
    }
    if (win.opener && !win.opener.closed) {
      win.opener.location.reload();
    }
  };

  let applied = false;
  const apply = function () {
    const w = document.defaultView;
    if (!w || !w.opener) return;

    store.removeExpiredKeys();
    const options = store.get(w.name);

    if (options == undefined) return;

    const window_listener = function () {
      $(document).on('click', '[data-toggle="window-close"]', function () {
        w.close();
      });

      $(this).on('keyup.esc_close', esc_closer);

      this.addEventListener('unload', function () {
        $(w.opener).focus();
      });

      if (options['reloadParentOnClose']) {
        this.addEventListener('unload', parent_reloader);
      }

      if (options['callbackOnClose']) {
        this.addEventListener('unload', function () {
          Function('"use strict"; return (' + options['callbackOnClose'] + ');')();
        });
      }
    };
    if (!applied) {
      window_listener();
      applied = true;
    }
  };

  const filter = function () {
    const w = document.defaultView;
    if (!w || !w.opener) {
      return $(); // 空
    }
    return $('body');
  };
  $.fn.apply_childwindow_actions = function () {
    filter.call($(this)).each(apply);
    return this;
  };
}());
