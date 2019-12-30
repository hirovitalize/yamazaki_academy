const Sentry = require('@sentry/browser')

// @see https://docs.sentry.io/quickstart/?platform=browsernpm#pick-a-client-integration
if (
  window.location.hostname.indexOf('coach-ac.info') >= 0
) {
  // 本番環境
  Sentry.init({
    dsn: 'https://e34ae4b0b3d94181828cec6feca3f6fd@sentry.io/1401702',
    environment: 'production'
    // beforeSend(event) {
    //   if (event.exception) {
    //     Sentry.showReportDialog({
    //       title: 'なんらかの不具合を検出しました。',
    //       subtitle: '不具合の調査にご協力ください。',
    //       subtitle2: '',
    //       labelName: '氏名',
    //       labelEmail: 'メールアドレス',
    //       labelComments: '発生事象・操作',
    //       labelClose: 'キャンセル',
    //       labelSubmit: '送信',
    //       errorGeneric: '送信に失敗しました。お手数ですが再送をお願いします。',
    //       errorFormEntry: '未入力の項目があります。修正の後に再送ください',
    //       successMessage: '送信しました。ご協力ありがとうございました'
    //     });
    //   }
    //   return event;
    // }
  });
}
