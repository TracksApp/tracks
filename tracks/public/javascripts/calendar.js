// Popup calendar date picker
// Written by Michele Tranquilli of pxl8.com 
// <http://www.pxl8.com/calendar_date_picker.html>

function Calendar_get_daysofmonth(monthNo, p_year) {
	if ((p_year % 4) == 0) {
		if ((p_year % 100) == 0 && (p_year % 400) != 0)
			return DOMonth[monthNo];
		return lDOMonth[monthNo];
	} else
		return DOMonth[monthNo];
}
// -- globals used with calendar and date functions
var calField; var calSpan; var calFormat; var calWknd = false;
/* ^^^^^^ end BASIC DATE  STARTER-SET ^^^^^^ */
function getNextMonth(m,y,incr){
	var ret_arr = new Array();
	ret_arr[0] = m + incr; ret_arr[1] = y;
	if (ret_arr[0] == 12){ ret_arr[0]=0; ret_arr[1]=ret_arr[1]+1; }
	if (ret_arr[0] == -1){ ret_arr[0]=11; ret_arr[1]=ret_arr[1]-1; }
	return ret_arr;
}
function figureDOTW(m,d,y){
	var tDate = new Date(); tDate.setDate(d); tDate.setMonth(m); tDate.setFullYear(y); return tDate.getDay();
}
function scramKids(n){ // this is a basic removeChild loop for removing all childNodes from node n
	var numKids = n.childNodes.length;
	for (i=0;i<numKids;i++) { n.removeChild(n.childNodes[0]); }
}		
function buildCalendar(m,y){
// -- requires: Basic Date Starter-Set, getNextMonth(), figureDOTW(), scramKids()
	m = parseFloat(m); y = parseFloat(y); 
	var dayNo = figureDOTW(m,1,y);
	var monthNo = Calendar_get_daysofmonth(m,y);
	var rowNum = Math.ceil((monthNo+dayNo)/7);
	var dayCount = 1;
	var calTB = document.getElementById('calTbl').getElementsByTagName('tbody')[0];
	var calNav = document.getElementById('calNav');
	scramKids(calTB);
	for (i=0;i<6;i++){ // row loop
		var calTR = document.createElement('tr');
		var calTDtext;
		var cellContent;
		for (j=0; j < 7; j++){ // cells in row loop, days in the week
			var calTD = document.createElement('td');
			if (j == 0 || j == 6 ) // weekends
				calTD.style.backgroundColor = '#EDF0FF';
			if ((i==0 && j < dayNo) || dayCount > monthNo) // cells before the first of the month or after the last day
				cellContent = document.createElement('br');
			else  {
				var dyA = document.createElement('a');
				dyA.setAttribute('href','javascript:placeDate('+m+','+dayCount+','+y+')');
				
				calTDtext = document.createTextNode(dayCount.toString());
				cellContent = calTDtext;
				if (dayCount == curr_dy && m == curr_mn && y == curr_yr)
						calTD.style.backgroundColor = '#FFFF99';
				if ((j!=0 && j!=6) || calWknd == true){ // if the day is a weekday or weekends allowed
					if (dayCount == curr_dy && m == curr_mn && y == curr_yr && calSpan != 3 && calSpan != 0 && calSpan != 4){
						dyA.appendChild(calTDtext); cellContent = dyA;
					}
					if (calSpan == 1 || calSpan == 4){
						if (y < curr_yr || (m < curr_mn && y == curr_yr) || (m == curr_mn && y == curr_yr && dayCount < curr_dy))
							{
							dyA.appendChild(calTDtext); cellContent = dyA;
							}
					} 
					if (calSpan == 2 || calSpan == 3){
						if (y > curr_yr || (m > curr_mn && y == curr_yr) || (m == curr_mn && y == curr_yr && dayCount > curr_dy))
							{dyA.appendChild(calTDtext); cellContent = dyA;}
					}
					if (calSpan == 5){
						dyA.appendChild(calTDtext); cellContent = dyA;
					}
				}
				else { /* else if it's a weekend */ }
				dayCount++;
			}
			calTD.appendChild(cellContent);
			calTD.setAttribute('width','14%');
			calTR.appendChild(calTD);
		}
		calTB.appendChild(calTR);
	}
	var nMonth = getNextMonth(m,y,+1);
	var pMonth = getNextMonth(m,y,-1);
	document.getElementById('calNavPY').innerHTML = '<a href="javascript:void(0)" onclick="buildCalendar('+m+','+(y-1)+')"><<</a>';
	document.getElementById('calNavPM').innerHTML = '<a href="javascript:void(0)" onclick="buildCalendar('+pMonth[0]+','+pMonth[1]+')"><</a>';
	document.getElementById('calNavMY').innerHTML = moty[m] +' '+y;
	document.getElementById('calNavNY').innerHTML = '<a href="javascript:void(0)" onclick="buildCalendar('+m+','+(y+1)+')">>></a>';
	document.getElementById('calNavNM').innerHTML = '<a href="javascript:void(0)" onclick="buildCalendar('+nMonth[0]+','+nMonth[1]+')">></a>';
}
function showCal(m,y,f,dateSpan,wknd,format){
	/* 
	dateSpan - date that should have links; does not include weekends
	0 = no dates
	1 = all past dates up to and including today
	2 = all future dates starting with today
	3 = all future dates NOT including today ( for GTC Dates )
	4 = all past dates NOT including today ( for start / from dates )
	5 = all dates
	*/
	calField = f; calSpan = dateSpan; calFormat = format; calWknd = wknd;
	if (m == '' && y == ''){m = curr_mn; y = curr_yr;}
	buildCalendar(m,y);
	document.getElementById('calDiv').style.display = '';
}
function placeDate(m,d,y){ 
	eval(calField).value = dateFormats(m,d,y,calFormat);
	document.getElementById('calDiv').style.display = 'none';
}
function dateFormats(m,d,y,calFormat){
	d = d.toString();
	m = m+1; m = m.toString();
	y = y.toString(); 
	var sy = y;
// -- convert to 2 digit numbers
	if (m.length == 1){m = '0'+ m;}
	if (d.length == 1){d = '0'+ d;}
	if (y.length == 4)
	 sy = y.substring(2,4);
	var format;
	switch (calFormat){
		case 0 : format = m + d + sy; break; 			//  mmddyy
		case 1 : format = m + d + y; break; 			//  mmddyyyy
		case 2 : format = m +'/'+ d +'/'+ y; break; 	//  mm/dd/yyyy
		case 3 : format = m +'/'+ d +'/'+ sy; break; 	//  mm/dd/yy
		case 4 : format = y + m; break; 				//  yyyymm
		case 5 : format = d + m + sy; break;			//  ddmmyy
		case 6 : format = d +'/'+ m +'/'+ sy; break; 	//  dd/mm/yy
		case 7 : format = d + m + y; break;				//  ddmmyyyy
		case 8 : format = d +'/'+ m +'/'+ y; break; 	//  dd/mm/yyyy
		case 9 : format = y +'-'+ m +'-'+ d; break;  // yyyy-mm-dd
		default: format = m + d + y; break; 			//  mmddyyyy
	}
	return format;
}