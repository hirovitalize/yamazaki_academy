module.exports = {
  /**
   * URLのGETパラメータとして任意の日付を渡す
   */
  changePageDate: function (value) {
    window.location.href = `${window.location.pathname}?date=${value}`
  }
}
