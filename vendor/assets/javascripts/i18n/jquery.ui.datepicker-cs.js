/* Czech initialisation for the jQuery UI date picker plugin. */
/* Written by Pavel Župa (pavel.zupa@gmail.com). */
jQuery(function($){
	$.datepicker.regional['cs'] = {
		closeText: 'zavřít',
		prevText: 'předchozí',
		nextText: 'další',
		currentText: 'dnes',
		monthNames: ['Leden','Únor','Březen','Duben','Květen','Červen',
		'Červenec','Srpen','Září','Říjen','Listopad','Prosinec'],
		monthNamesShort: ['Led','Úno','Bře','Dub','Kvě','Čer',
		'Čec','Srp','Zář','Říj','Lis','Pro'],
		dayNames: ['Neděle','Pondělí','Úterý','Středa','Čtvrtek','Pátek','Sobota'],
		dayNamesShort: ['Ne','Po','Út','St','Čt','Pá','So'],
		dayNamesMin: ['Ne','Po','Út','St','Čt','Pá','So'],
		weekHeader: 'č.',
		dateFormat: 'dd.mm.yy',
		firstDay: 1,
		isRTL: false,
		showMonthAfterYear: false,
		yearSuffix: ''};
	$.datepicker.setDefaults($.datepicker.regional['cs']);
});
