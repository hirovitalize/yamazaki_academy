/**
 * Ajax でフォームの値を更新したときにアイコンでフィードバックを表示する
 */

/* global $ */

class IconFeedback {
  constructor(selector) {
    this.$icon = $(selector).after('<i class="fa fa-check ml-2 text-success"></i>').next().hide()
  }

  success () {
    this.$icon.fadeIn().delay(1200).fadeOut()
  }
}

module.exports = IconFeedback
