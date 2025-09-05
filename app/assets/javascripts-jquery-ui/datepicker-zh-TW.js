/* Traditional Chinese (Taiwan) initialisation for the jQuery UI date picker plugin. */
/* Written by Claude Code for Tracks application. */
( function( factory ) {
	"use strict";

	if ( typeof define === "function" && define.amd ) {

		// AMD. Register as an anonymous module.
		define( [ "../widgets/datepicker" ], factory );
	} else {

		// Browser globals
		factory( jQuery.datepicker );
	}
} )( function( datepicker ) {
"use strict";

datepicker.regional["zh-TW"] = {
	closeText: "關閉",
	prevText: "上一月",
	nextText: "下一月",
	currentText: "今天",
	monthNames: [ "一月", "二月", "三月", "四月", "五月", "六月",
	"七月", "八月", "九月", "十月", "十一月", "十二月" ],
	monthNamesShort: [ "1月", "2月", "3月", "4月", "5月", "6月",
	"7月", "8月", "9月", "10月", "11月", "12月" ],
	dayNames: [ "星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六" ],
	dayNamesShort: [ "日", "一", "二", "三", "四", "五", "六" ],
	dayNamesMin: [ "日", "一", "二", "三", "四", "五", "六" ],
	weekHeader: "週",
	dateFormat: "yy/mm/dd",
	firstDay: 0,
	isRTL: false,
	showMonthAfterYear: true,
	yearSuffix: "年" };
datepicker.setDefaults( datepicker.regional["zh-TW"] );

return datepicker.regional["zh-TW"];

} );