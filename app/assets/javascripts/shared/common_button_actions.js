/**
 * 全画面共通用のボタンアクション
 *
 * js-form-save-button
 */

/* global $ */
/* global swal */

const Swal = require('module/swal')
const SwalDefault = Swal.swalDefault()

$(function () {
  $('button.js-form-save-button').each(function () {
    const $form = $(this).parents('form')

    $(this).click(function (evt) {
      evt.preventDefault()

      SwalDefault({
        type: 'question',
        title: '保存します。よろしいですか',
        showCancelButton: true,
        confirmButtonText: '保存する',
        cancelButtonText: Swal.cancelButtonText
      })
      .then(function (result) {
        if (!result.value) return

        swal.showLoading()
        $form.submit()
      })
    })
  })
})