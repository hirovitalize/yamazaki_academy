const AjaxConstants = require('module/ajax_constants')

/* global $ */
/* global moment */
/* global URLSearchParams */

$(function () {
  const lectures = function (start, end, klass_id, timezone, callback) {
    $.ajax($.extend({}, AjaxConstants.optionDefaults, {
      type: 'GET',
      url: '/klasses/' + klass_id + '/curriculum_schedule',
      async: false,
      dataType: 'json',
      data: {
        start_date: moment(start).format('L'),
        end_date: moment(end).format('L'),
      }
    })).done(function (lectures) {
      callback(lectures.map(function (lecture) {
        return {
          id: lecture.id,
          title: lecture.subject_name + ' ' + (!!lecture.staff_names ? lecture.staff_names : 'スタッフ未設定'),
          start: lecture.start_time,
          end: lecture.finish_time,
          url: '/lectures/' + lecture.id
        };
      }));
    }).fail(AjaxConstants.fail);
  };

  const locale = function () {
    const params = new URLSearchParams(window.location.search);
    const map = {
      zh: 'zh-cn',
      en: 'en',
      ja: 'ja'
    };
    if (!params.get('locale')) return 'ja';
    return map[params.get('locale').toLowerCase()] || 'ja';
  };

  $('.calendar').each(function () {
    const klass_id = $(this).data('klass_id');
    const date = $(this).data('month');
    $(this).fullCalendar({
      locale: locale(),
      timezone: 'local',
      header: {
        left: 'title',
        center: '',
        right: ''
      },
      defaultDate: date,
      contentHeight: 450,
      editable: false,
      selectable: false,
      nowIndicator: true,
      firstDay: 1, // 月曜日から
      showNonCurrentDates: false, // 他の月は表示しない
      timeFormat: 'HH:mm',
      events: function (start, end, timezone, callback) {
        lectures(
          start.format('YYYY-MM-DD'),
          end.format('YYYY-MM-DD'),
          klass_id,
          timezone,
          callback
        );
      },
      schedulerLicenseKey: '0347020785-fcs-1540970035'
    });
  });
});
