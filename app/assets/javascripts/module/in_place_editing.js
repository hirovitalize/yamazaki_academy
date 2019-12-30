/**
 * In-place editor を実装するモジュール
 */

/* global $ */

const ApiClient = require('module/api_client')

class InPlaceEditing {
  /**
   * @params {String} models 更新対象のモデル名
   * @params {String} column 更新対象のカラム名
   * @params {Object} params 同時に更新したいカラムと値のセット
   */
  constructor(models, column, params = {}) {
    const store = {
      originalVal: null
    }

    $('[contenteditable="true"]').on('focus', function () {
      store.originalVal = $(this).text().replace(',', '')
    })

    $('[contenteditable="true"]').on('blur', function () {
      const $self = $(this)
      const id = $self.data('id')
      const val = $self.text().replace(',', '')

      // 下記のいずれかの場合は編集前の値に戻して処理を終了する
      //  1. 編集前後で値が変わっていない
      //  2. 正の整数ではない
      if (store.originalVal === val || !/^([1-9]\d*|0)$/.test(val)) {
        $self.text(Number(store.originalVal).toLocaleString())
        return
      }

      ApiClient
        .update(models, id, Object.assign({ [column]: val }, params))
        .done(function () {
          $self.addClass('text-success')
        })
    })
  }
}

module.exports = InPlaceEditing