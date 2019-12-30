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
    minTime: '09:00', //時間スロット開始
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
      { labelText: i18n_text.data('klass_name'), field: 'klassName' },
    ],
    resources: fetchKlasses,
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
        url: '/lectures/klass_calendar',
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
            id: lecture.key,
            resourceId: lecture.klass_id,
            title: lecture.name,
            subject_name: lecture.subject_name,
            staff_name: lecture.staff_name,
            start: lecture.start_time,
            end: lecture.finish_time,
            color: event_color(lecture),
            url: '/lectures/' + lecture.id
          }
        }))
      })
      .fail(AjaxConstants.fail)
  }

  /**
   * イベントのHTML作り直し＆ツールチップ適応
   */
  function custom_event_html(event, element) {
    var content = $(element).find('.fc-content')
    content.html(
      moment(event.start).format(Constants.timeFormat) + '<br>' +
      moment(event.end).format(Constants.timeFormat) + '<br>' +
      (!!event.staff_name ? (event.staff_name + '<br>') : '') +
      (!!event.subject_name ? (event.subject_name + '<br>') : '')
    )

    $(element).tooltip({
      html: true,
      title: (!!event.staff_name ? ('(スタッフ)' + event.staff_name + '<br>') : '') +
        (!!event.subject_name ? ('(科目)' + event.subject_name + '<br>') : '') +
        (!!event.title ? ('(授業)' + event.title + '<br>') : ''),
      container: "body"
    });
  }

  /**
   * リソースのHTML編集
   */
  function custom_resource_html(resourceObj, labelTds, bodyTds) {}

  /**
   * クラス一覧を取得する
   */
  function fetchKlasses(callback) {
    const klass_ids = $('.js-klass-calendar').data('klass_ids');

    callback(
      ApiClient.fetch('klasses', { without_deleted: true, id_in: klass_ids }).map(function (klass) {
        return {
          id: klass.id,
          klassName: klass.name
        };
      })
    );
  }

  /**
   * キャンセルの授業は色変更
   */
  function event_color(lecture) {
    if (!!lecture['canceled_status']) return '#747474';

    return '#3a87ad';
  }
});
