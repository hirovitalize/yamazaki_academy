/* global $ */
/* global moment */

/**
 * 開始日時を入力したら、終了日時のフォームにも日付の値を自動入力する
 * 数ヶ月以上先の日付を入力する場合に、カレンダーUIから日付を選択する手間を省く
 *
 * to: 終了日時フォームのセレクタ
 * addedDays: 開始日時から${addedDays}日後の日付を入力（デフォルトは1週間後）
 * addedMinutess: 開始日時から${addedMinutes}分後の日付を入力（デフォルトは0分後） addedDaysと一緒に使用可能
 * overwrite: 入力済みの場合に上書きするかどうか (default: false)
 * dateFormat: 日付フォーマット
 **/
(function () {
  const applyer = function () {
    const $self = $(this);
    $self.on('change', function () {
      const datein = $self.val();
      if (!datein) return;
      const config = $self.data('autofill');
      const $target = $self.nearest(config['to']);
      const added_year = config['added_year'] !== undefined ? config['added_year'] : 0;
      const added_days = config['added_days'] !== undefined ? config['added_days'] : 7;
      const added_minutes = config['added_minutes'] !== undefined ? config['added_minutes'] : 0;
      const overwrite = config['overwrite'] !== undefined ? !!config['overwrite'] : false;
      const format = config['date_format'] || 'YYYY/MM/DD';

      // 終了日時が空の場合のみ自動入力する
      if (!$target.val() || overwrite) {
        const d = moment(datein, format).add(added_year, 'year').add(added_days, 'days').add(added_minutes, 'minutes');
        $target.val(d.format(format)).trigger('change');
      }
    });
  };

  const filter = function () {
    return $(this).find('[data-toggle="autofill_date"]');
  };

  $.fn.apply_autofill_date = function () {
    filter.call($(this)).each(applyer);
    return this;
  };
}());
