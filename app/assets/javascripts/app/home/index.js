/* global $ */
/* global URLSearchParams */

$(function () {
  const lectures = function (start, end, staff_id, timezone, callback) {
    $.ajax({
        type: 'GET',
        url: '/home/lectures_for_reserves?start_date=' + start + '&end_date=' + end + '&staff_id=' + staff_id,
        async: false,
        dataType: 'json',
        data: {
          start_date: start,
          end_date: end,
          staff_id: staff_id
        }
    }).then(function (data) {
      var results = [];

      $.each(data, function (index, value) {
        results.push({
          id: value['id'],
          title: value['canceled_status'] ? ('【キャンセル】' + value['name']) : value['name'],
          start: value['start_time'],
          end: value['finish_time'],
          url: '/lectures/' + value['id'],
          color: event_color(value)
        });
      });
      callback(results);
    });
  };

  function event_color(value) {
    //キャンセルされた授業
    if (!!value['canceled_status']) return '#747474';

    // VIPか初回面談 ＆ 予約有の授業
    if (value['personal'] && value['reserve_id'] !== null) return '#fa8000';

    // VIPか初回面談 & 予約無の授業
    if (value['personal'] && value['reserve_id'] == null) return '#ffa965';

    // 集団の授業
    return '#3a87ad';
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

  $('#calendar').fullCalendar({
    locale: locale(),
    timezone: 'local',
    header: {
      left: 'prev next title',
      center: '',
      right: ''
    },
    editable: false,
    selectable: false,
    nowIndicator: true,
    firstDay: 1, // 月曜日から
    timeFormat: 'HH:mm',
    height: window.innerHeight - 100,
    events: function (start, end, timezone, callback) {
      lectures(
        start.format('YYYY-MM-DD'),
        end.format('YYYY-MM-DD'),
        $('#calendar').data('staff_id'),
        timezone,
        callback
      );
    },
    schedulerLicenseKey: '0347020785-fcs-1540970035'
  });
});
