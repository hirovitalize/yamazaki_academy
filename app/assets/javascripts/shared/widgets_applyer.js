//= require shared/assign_me
//= require shared/autocomplete_select
//= require shared/autofill_date
//= require shared/childwindow
//= require shared/childwindow_actions
//= require shared/colorpicker
//= require shared/datepicker
//= require shared/datetimepicker
//= require shared/drilldown_select
//= require shared/postcode
//= require shared/select2
//= require shared/select_all
//= require shared/tablesorter
//= require shared/timepicker
//= require shared/tooltip

//= require shared/cocoon_appended

/* global jQuery */
/* global _ */

(function ($) {
    var widget_applyers = {
        assign_me: $.fn.apply_assign_me,
        autocomplete_select: $.fn.apply_autocomplete_select,
        autofill_date: $.fn.apply_autofill_date,
        childwindow: $.fn.apply_childwindow,
        childwindow_actions: $.fn.apply_childwindow_actions,
        colorpicker: $.fn.apply_colorpicker,
        datepicker: $.fn.apply_datepicker,
        datetimepicker: $.fn.apply_datetimepicker,
        drilldown_select: $.fn.apply_drilldown_select,
        postcode: $.fn.apply_postcode,
        select2: $.fn.apply_select2,
        select_all: $.fn.apply_select_all,
        tablesorter: $.fn.apply_tablesorter,
        timepicker: $.fn.apply_timepicker,
        tooltip: $.fn.apply_tooltip,
        cocoon_appended: $.fn.apply_cocoon_appended,
    }

    $.fn.set_widget = function (name, func) {
        widget_applyers[name] = func
        return this
    }

    $.fn.apply_widget = function (name) {
        widget_applyers[name].call(this)
        return this
    }

    $.fn.apply_widgets = function () {
        var $elem = this
        _.each(widget_applyers, function (applyer, name) {
            applyer.call($elem)
        })
        return this
    }
    $(function () {
        $('body').apply_widgets()
    })
}(jQuery))
