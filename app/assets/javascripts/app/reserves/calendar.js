/* global $ */
/* global _ */
/* global moment */
/* global gon */
/* global URLSearchParams */

const ApiClient = require('module/api_client')
const AjaxConstants = require('module/ajax_constants')
const Constants = require('module/constants')
const Fullcalendar = require('module/fullcalendar')
const Swal = require('module/swal')

const swalDefault = Swal.swalDefault()

$(function () {
  // ドラッグ可能要素を作成
  $('#external-events .fc-event').each(function () {
    // store data so the calendar knows to render an event upon drop
    $(this).data('event', {
      title: $.trim($(this).text()),
      lecture_id: $(this).data('lecture_id'),
      start: $(this).data('start_time'),
      end: $(this).data('finish_time')
    });

    // make the event draggable using jQuery UI
    $(this).draggable({
      zIndex: 999,
      revert: true, // will cause the event to go back to its
      revertDuration: 0 //  original position after the drag
    });
  });

  const _$calendar = $('#calendar')

  const i18n_text = $('.js-hidden-text-reserve')

  const store = {
    // 講義セレクトボックス用に整えられた予約者リスト
    formattedLectures: null
  }

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
      right: ''
    },
    defaultView: 'timelineDay',
    minTime: '9:00', //時間スロット開始
    maxTime: '22:00', //時間スロット終了
    defaultDate: moment(gon.date, 'L'),
    editable: true,
    nowIndicator: true,
    slotDuration: '01:00:00', // 表示する時間軸の細かさ
    snapDuration: '00:15:00', // スケジュールをスナップするときの動か
    height: window.innerHeight - 100,
    views: {
      timelineDay: {
        titleFormat: 'YYYY/M/D[(]ddd[)]',
      },
    },

    resourceColumns: [
      { labelText: i18n_text.data('room_name'), field: 'roomName', width: '85%' },
      { labelText: i18n_text.data('capacity'), field: 'capacity', width: '15%' }
    ],
    /*
        resourceColumns: [
          { labelText: '地域', field: 'areaName', width: '20%', group: true },
          { labelText: '建物', field: 'buildingName', width: '30%', group: true },
          { labelText: '教室名', field: 'roomName', width: '30%' },
          { labelText: '定員', field: 'capacity', width: '20%' }
        ],
    */
    // resourcesInitiallyExpanded: false,
    resources: fetchRooms,
    resourceRender: custom_resource_html,

    selectable: true,
    selectMinDistance: 2,
    selectOverlap: false,
    select: selectLecture,

    events: fetchReserves,
    eventRender: custom_event_html,

    eventOverlap: false,
    eventDrop: updateReserve,
    eventResize: updateReserve,

    eventClick: deleteReserve,

    droppable: true,
    drop: createiLectureByDrop
  }))

  /**
   * 表示日の予約一覧を取得する
   */
  function fetchReserves(start, end, timezone, callback) {
    $.ajax($.extend({}, AjaxConstants.optionDefaults, {
        type: 'GET',
        url: '/reserves/calendar',
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
            color: event_color(reserve),
            editable: editable
          }
        }))
      })
      .fail(AjaxConstants.fail)
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

  /**
   * ドラッグ＆ドロップでリザーブを作成する
   */
  function createiLectureByDrop(date, jsEvent, ui, resourceId) {
    const lecture = $(this);
    const remaining_lectures = lecture.parent().children().length;
    const klass = lecture.parent().parent().parent().parent().attr('id');

    ApiClient.create('reserves', {
        lecture_id: this.dataset.lecture_id,
        room_id: resourceId,
        start_time: this.dataset.start_time,
        finish_time: this.dataset.finish_time
      })
      .done(function () {
        lecture.remove();
      })
      .done(function () {
        if ( remaining_lectures === 1 ){
          $('#' + klass).remove();
        }
      });
    _$calendar.fullCalendar('refetchEvents');
  }

  /**
   * 表示日を期間に含む予約一覧を取得する
   * セレクトボックスに表示する形式に変換する
   */
  function fetchLectures(view) {
    const lectures = ApiClient.fetch('lectures', {
      date_range_included: moment(view.start).format('L'),
      time_changeable_true: true,
      not_reserved: true,
      not_canceled: true
    })

    store.formattedLectures = lectures.reduce(function (obj, lec) {
      obj[lec.id] = `【${moment(lec.start_time).format(Constants.datetimeFormat)} ~ ${moment(lec.finish_time).format(Constants.datetimeFormat)}】${lec.name}`
      return obj
    }, {})
  }

  /**
   * 講義選択ポップアップを表示する
   */
  function selectLecture(start, end, jsEvent, view, resource) {
    if (view_event_creatable(view)) return
    if (resource.eventClassName == 'buil') return

    const startAt = moment(start).format(Constants.datetimeFormat)
    const endAt = moment(end).format(Constants.datetimeFormat)

    if (checkTenMinutesGt(start, end)) {
      validSwal(i18n_text.data('swal_text_valid_ten_minutes'))
      return
    }

    fetchLectures(start)

    if (_.isEmpty(store.formattedLectures)) {
      validSwal(i18n_text.data('swal_text_valid_empty_lectures'))
      return
    }

    swalDefault({
        html: `${startAt} 〜 ${endAt}<br>${i18n_text.data('swal_select_description_text')}`,
        input: 'select',
        inputOptions: store.formattedLectures,
        confirmButtonText: i18n_text.data('confirm_button_reserve'),
        showCancelButton: true,
        cancelButtonText: Swal.cancelButtonText
      })
      .then(function (result) {
        if (!result.value) return
        return ApiClient.create('reserves', {
          lecture_id: result.value,
          room_id: resource.id,
          start_time: startAt,
          finish_time: endAt
        })
      })
      .then(function (result) {
        $('div[data-lecture_id="' + result.lecture_id + '"]').remove()
        _$calendar.fullCalendar('refetchEvents')
      })
  }

  /**
   * 予約削除ポップアップを表示する
   */
  function deleteReserve(event) {
    const id = event.id
    swalDefault({
        text: i18n_text.data('swal_confirm_text_delete'),
        confirmButtonText: i18n_text.data('confirm_button_delete'),
        confirmButtonClass: Swal.dangerButtonClass,
        showCancelButton: true,
        cancelButtonText: Swal.cancelButtonText
      })
      .then(function (result) {
        if (!result.value) return
        $.ajax($.extend({}, AjaxConstants.optionDefaults, {
          type: 'DELETE',
          url: '/reserves/' + id,
          async: false,
          dataType: 'json'
        }))
        setTimeout("location.reload()", 10);
      })
      .then(function () {
        _$calendar.fullCalendar('refetchEvents')
      })
  }

  /**
   * アサインを更新する
   */
  function updateReserve(event, delta, revertFunc) {
    const view = _$calendar.fullCalendar('getView')
    if (view_event_creatable(view)) {
      revertFunc()
      return
    }

    const id = event.id
    const roomId = event.resourceId
    const startAt = moment(event.start).format(Constants.datetimeFormat)
    const endAt = moment(event.end).format(Constants.datetimeFormat)

    if (checkTenMinutesGt(event.start, event.end)) {
      validSwal(i18n_text.data('swal_text_valid_ten_minutes'))
      revertFunc()
      return
    }

    // 期間が重複しているアサインがあるかどうかを確認する
    const reserved = ApiClient.fetch('reserves', {
      id_not_eq: id,
      room_id_eq: roomId,
      start_time_lt: endAt,
      finish_time_gt: startAt
    })

    if (reserved.length) {
      revertFunc()
      return
    }

    ApiClient.update('reserves', id, {
      room_id: roomId,
      start_time: startAt,
      finish_time: endAt
    })

    _$calendar.fullCalendar('refetchEvents')
  }

  /**
   * eventを作成して良いviewか判定する
   */
  function view_event_creatable(view) {
    return /timelineMonth|timelineYear/.test(view.name)
  }

  /**
   * 時間幅が15分以上かチェックする
   */
  function checkTenMinutesGt(start, end) {
    const minutes = moment(end).diff(moment(start), 'minutes')
    return minutes < 30
  }

  /**
   * バリデーションエラー系のキャンセルswal
   */
  function validSwal(text) {
    swalDefault({
      text: text,
      showConfirmButton: false,
      showCancelButton: true,
      cancelButtonText: Swal.closeButtonText
    })
  }
})
