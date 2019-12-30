/**
 * Select2 を有効化する
 */

/* global $ */

class Select2 {
  constructor(el) {
    const $el = $(el)
    $el.select2({
      language: { noResults: () => '該当するものがありません' },
      theme: 'bootstrap',
      placeholder: $el.attr('placeholder'),
      width: '100%'
    })
  }
}

module.exports = Select2