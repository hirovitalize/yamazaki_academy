/* global $ */
(function () {
    const html5_attributes = [
        'required', 'pattern',
        'maxlength', 'minlength',
        'max', 'min', 'step'
    ];

    var apply = function () {
        var $self = $(this);
        $self.on('cocoon:after-insert', function (evt, dom) {
            $(dom).apply_widgets(); // 循環require が生じるため、明示的にはload しない
        });
        $self.on('cocoon:after-remove', function (evt, dom) {
            // HTML5 validationを発動させない
            $(dom)
                .find('input, textarea, select')
                .not('[name$="[_destroy]"]') // 削除フラグは残す
                .removeAttr(html5_attributes.join(' '))
                .prop('disabled', 'disabled')
                .each(function () { // すでに判定がついていたらクリア
                    this.setCustomValidity('');
                });
        });
    };
    var filter = function () {
        return $(this).find('.cocoon-append-target');
    };
    $.fn.apply_cocoon_appended = function () {
        filter.call($(this)).each(apply);
        return this;
    };
}());
