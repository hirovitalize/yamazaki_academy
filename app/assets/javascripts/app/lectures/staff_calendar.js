/* global $ */
/* global _ */
/* global moment */
/* global gon */
/* global URLSearchParams */

const ApiClient = require('module/api_client')
const AjaxConstants = require('module/ajax_constants')
const Constants = require('module/constants')
const Fullcalendar = require('module/fullcalendar')

$(function () {
  const _$calendar = $('#calendar');

  const i18n_text = $('.js-hidden-text-reserve')

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

  // カレンダーの初期化設定
  _$calendar.fullCalendar($.extend({}, Fullcalendar.optionDefaults, {
    locale: locale(),
    timezone: 'local',
    bootstrapFontAwesome: {
      reFetchButton: 'fa-repeat'
    },
    customButtons: {
      reFetchButton: {
        click: function () {
          _$calendar.fullCalendar('refetchEvents');
        }
      }
    },
    header: {
      left: 'title',
      center: '',
      right: 'timelineWeek timelineMonth'
    },
    defaultView: 'timelineWeek',
    minTime: '9:00', //時間スロット開始
    maxTime: '22:00', //時間スロット終了
    defaultDate: moment(gon.date, 'L'),
    nowIndicator: true,
    firstDay: moment().day(),
    slotDuration: '03:00:00',
    height: window.innerHeight - 100,
    views: {
      timelineWeek: {
        titleFormat: 'YYYY/M/D',
        slotDuration: '24:00:00',
      },
      timelineMonth: {
        titleFormat: 'YYYY/M',
        slotDuration: '24:00:00',
      },
    },

    resourceColumns: [
      { labelText: i18n_text.data('staff_name'), field: 'staffName' }
    ],
    resources: fetchStaffs,
    resourceRender: custom_resource_html,

    events: fetchLectures,
    eventClick: function (event) {
    if (event.url) {
        window.open(event.url, "_blank");
        return false;
      }
    },

    eventRender: custom_event_html
  }))

  /**
   * 表示日の予約一覧を取得する
   */
  function fetchLectures(start, end, timezone, callback) {
    $.ajax($.extend({}, AjaxConstants.optionDefaults, {
        type: 'GET',
        url: '/lectures/staff_calendar',
        async: false,
        dataType: 'json',
        data: {
          start_date: moment(start).format('L'),
          end_date: moment(end).format('L'),
        }
      }))
      .done(function (lectures) {
        callback(lectures.map(function (lecture) {
          return {
            id: lecture.lsid,
            resourceId: lecture.staff_id,
            title: lecture.name,
            subject_name: lecture.subject_name,
            start: lecture.start_time,
            end: lecture.finish_time,
            url: '/lectures/' + lecture.id,
            color: event_color(lecture)
          }
        }))
      })
      .fail(AjaxConstants.fail)
  }

  function event_color(lecture) {
    //キャンセルされた授業
    if (!!lecture['canceled_status']) return '#747474';

    // VIPか初回面談 ＆ 予約有の授業
    if (lecture['subject_personal'] && lecture['reserve_id'] !== null) return '#fa8000';

    // VIPか初回面談 & 予約無の授業
    if (lecture['subject_personal'] && lecture['reserve_id'] == null) return '#ffa965';

    // 集団の授業
    return '#3a87ad';
  }

  /**
   * イベントのHTML作り直し＆ツールチップ適応
   */
  function custom_event_html(event, element) {
    var content = $(element).find('.fc-content')
    content.html(
      moment(event.start).format(Constants.timeFormat) + '<br>' +
      moment(event.end).format(Constants.timeFormat) + '<br>' +
      (!!event.title ? (event.title + '<br>') : '')
    )

    $(element).tooltip({
      html: true,
      title: (!!event.subject_name ? ('(科目)' + event.subject_name + '<br>') : '') +
        (!!event.title ? ('(授業)' + event.title + '<br>') : ''),
      container: "body"
    });
  }

  /**
   * リソースのHTML編集
   */
  function custom_resource_html(resourceObj, labelTds, bodyTds) {}

  /**
   * スタッフの一覧を取得する
   */
  function fetchStaffs(callback) {
    const staff_ids = $('.js-staff-calendar').data('staff_ids');

    callback(
      ApiClient.fetch('staffs', { without_deleted: true, id_in: staff_ids }).map(function (staff) {
        return {
          id: staff.id,
          staffName: (staff.code ? '[' + staff.code + ']' : '') + staff.name
        };
      })
    );
  }
});
