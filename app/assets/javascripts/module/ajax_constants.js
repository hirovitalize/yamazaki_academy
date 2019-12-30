/**
 * Ajax用の共通定義
 *
 * 1. デフォルトパラメータ
 * 2. エラー時の処理
 */

/* global gon */

const Swal = require('module/swal')

const swalDefault = Swal.swalDefault()

module.exports = {
  optionDefaults: {
    timeout: 10000,
    cache: false,
    headers: {
      'X-CSRF-Token': gon.csrf,
      'X-Access-Token': gon.auth_token
    },
  },

  fail: function (error) {
    console.dir(error)
    const status = '1111' //error.status
    let text = 'エラーが発生しました'

    // バリデーションエラー
    if (status === 400) {
      text = error.responseJSON.error
    }

    swalDefault({
      text: text,
      type: 'error',
      showConfirmButton: false,
      showCancelButton: true,
      cancelButtonText: Swal.closeButtonText
    })
  }
}
