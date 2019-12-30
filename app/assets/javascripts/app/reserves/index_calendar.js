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
      left: 'today prev next title',
      center: '',
      right: 'timelineWeek timelineMonth'
    },
    defaultView: 'timelineWeek',
    minTime: '9:00', //時間スロット開始
    maxTime: '22:00', //時間スロット終了
    defaultDate: moment(gon.date, 'L'),
    nowIndicator: true,
    firstDay: moment().day(),
    slotDuration: '03:00:00', // 表示する時間軸の細かさ
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
      { labelText: i18n_text.data('room_name'), field: 'roomName', width: '80%' },
      { labelText: i18n_text.data('capacity'), field: 'capacity', width: '20%' }
    ],
    resources: fetchRooms,
    resourceRender: custom_resource_html,

    events: fetchReserves,
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
  function fetchReserves(start, end, timezone, callback) {
    $.ajax($.extend({}, AjaxConstants.optionDefaults, {
        type: 'GET',
        url: '/reserves/index_calendar',
        async: false,
        dataType: 'json',
        data: {
          start_date: moment(start).format('L'),
          end_date: moment(end).format('L'),
        }
      }))
      .done(function (reserves) {
        callback(reserves.map(function (reserve) {
          var editable = true
          if (reserve.time_changeable == 0) {
            editable = false
          }

          return {
            id: reserve.id,
            resourceId: reserve.room_id,
            title: reserve.lecture_name,
            klass_name: reserve.klass_name,
            subject_name: reserve.subject_name,
            subject_pesonal: reserve.subject_pesonal,
            comment: reserve.comment,
            start: reserve.start_time,
            end: reserve.finish_time,
            url: specify_url(reserve),
            color: event_color(reserve),
            editable: editable
          }
        }))
      })
      .fail(AjaxConstants.fail)
  }

  function specify_url(reserve) {
    if (!reserve.lecture_id) return '/reserves/' + reserve.id;

    return '/lectures/' + reserve.lecture_id;
  }

  function event_color(reserve) {
    if (!reserve.lecture_id) return 'black';

    if (reserve.subject_pesonal) return '#fa8000';

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
      (!!event.title ? (event.title + '<br>') : '') +
      (!!event.comment ? (event.comment) : '')
    )

    $(element).tooltip({
      html: true,
      title: (!!event.klass_name ? ('(クラス)' + event.klass_name + '<br>') : '') +
        (!!event.subject_name ? ('(科目)' + event.subject_name + '<br>') : '') +
        (!!event.title ? ('(授業)' + event.title + '<br>') : '') +
        (!!event.comment ? ('(概要)' + event.comment) : ''),
      container: "body"
    });
  }

  /**
   * リソースのHTML編集
   */
  function custom_resource_html(resourceObj, labelTds, bodyTds) {
    if (resourceObj.eventClassName == 'buil') {
      bodyTds.css('background', '#f0f3f5')
    }
  }

  /**
   * 部屋一覧を取得する
   */
  function fetchRooms(callback) {
    const room_ids = $('.js-reserve-calendar').data('room_ids')
    $.ajax($.extend({}, AjaxConstants.optionDefaults, {
      type: 'GET',
      url: '/reserves/rooms_for_calendar',
      async: false,
      dataType: 'json',
      data: {
        ids: room_ids.join(','),
      }
    })).done(function (rooms) {

      rooms = rooms.sort(function(a, b){
              if(a.building_id > b.building_id) return 1;
              if(a.building_id < b.building_id) return -1;
              if(a.name > b.name) return 1;
              if(a.name < b.name) return -1;
              return 0;
              });

      callback(rooms.map(function (room) {
        return {
          id: room.id,
          roomName: room.name + ' ' + room.buildings_name,
          capacity: room.seat_number
        };
      }));
    }).fail(AjaxConstants.fail);
  }
});
