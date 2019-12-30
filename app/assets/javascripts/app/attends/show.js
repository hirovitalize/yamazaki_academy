const QRCode = require('qrcode')

/* global $ */

$(function () {
  const canvas = document.getElementById('js-url-attends')
  if (!canvas) return false;

  QRCode.toCanvas(canvas, $(canvas).data('url'), function (error) {
    if (error) {
      canvas.appendChild('<div>' + error + '</div>');
    }
  })
})
