/* global $ */
/* global swal */

module.exports = {
  submitButtonClass: 'btn btn-primary mr-3 ml-3',
  linkButtonClass: 'btn btn-info mr-3 ml-3',
  cancelButtonClass: 'btn btn-secondary mr-3 ml-3',
  warningButtonClass: 'btn btn-warning mr-3 ml-3',
  dangerButtonClass: 'btn btn-danger mr-3 ml-3',

  closeButtonText: '閉じる',
  cancelButtonText: 'キャンセル',

  /**
   * ポップアップ内のすべてのボタンからフォーカスを外す
   * エンターキーの誤操作防止
   */
  blurAllButtons: function () {
    $(swal.getActions()).find(':focus').blur()
    $(swal.getFooter()).find(':focus').blur()
  },

  /**
   * Bootstrapに対応したポップアップを表示する
   * 基本的に素のswalではなくこちらを使用する
   */
  swalDefault: function () {
    return swal.mixin({
      confirmButtonClass: this.submitButtonClass,
      cancelButtonClass: this.cancelButtonClass,
      buttonsStyling: false,
      onOpen: this.blurAllButtons
    })
  },

  /**
   * トースト形式でポップアップを表示する
   */
  swalToast: function () {
    return swal.mixin({
      toast: true,
      position: 'top-end',
      showConfirmButton: false,
      timer: 3000
    })
  }
}
