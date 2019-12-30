/**
 * 指定の要素にオーバレイでローディングアイコンを表示させるモジュール
 */

/* global $ */
/* global _ */

class BoxLoading {
  constructor(selector) {
    this.$box = $(selector)
  }

  on () {
    if (_.isEmpty(this.$box.find('.overlay'))) {
      this.$box.append('<div class="overlay"><i class="fa fa-refresh fa-spin"></div>')
    }
    $('.overlay').show()
  }

  off () {
    $('.overlay').hide()
  }
}

module.exports = BoxLoading