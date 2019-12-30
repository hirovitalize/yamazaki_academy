const QRCode = require('qrcode')

/* global $ */

$(function () {
  const canvas = document.getElementById('js-url')
  if (!canvas) return false;

  QRCode.toCanvas(canvas, window.location.href, function (error) {
    if (error) {
      canvas.appendChild('<div>' + error + '</div>');
    }
  })
})
