/* Today's date */
var DOMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
var lDOMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
var moty = ["January","February","March","April","May","June","July","August","September","October","November","December"];

function Calendar_get_daysofmonth(monthNo, p_year) {
	if ((p_year % 4) == 0) {
		if ((p_year % 100) == 0 && (p_year % 400) != 0)
			return DOMonth[monthNo];
		return lDOMonth[monthNo];
	} else
		return DOMonth[monthNo];
}

function getNextMonth(m,y,incr){
	var ret_arr = new Array();
	ret_arr[0] = m + incr; ret_arr[1] = y;
	if (ret_arr[0] == 12){ ret_arr[0]=0; ret_arr[1]=ret_arr[1]+1; }
	if (ret_arr[0] == -1){ ret_arr[0]=11; ret_arr[1]=ret_arr[1]-1; }
	return ret_arr;
}
function figureDOTW(m,d,y){
	var tDate = new Date(); tDate.setDate(d); tDate.setMonth(m); tDate.setYear(y); return tDate.getDay();
}
function scramKids(n){ // this is a basic removeChild loop for removing all childNodes from node n
	var numKids = n.childNodes.length;
	for (i=0;i<numKids;i++) { n.removeChild(n.childNodes[0]); }
}		
function buildCalendar(m,y,ff){
	var dayNo = figureDOTW(m,1,y);
	var monthNo = Calendar_get_daysofmonth(m,y);

	var dayCount = 1;
	var calTB = document.getElementById('calTbl').getElementsByTagName('tbody')[0];
	var calNav = document.getElementById('calNav');
	scramKids(calTB);
	for (i=0;i<6;i++){ // row loop
		var calTR = document.createElement('tr');
		var calTDtext;
		
		for (j=0; j < 7; j++){ // cells in row loop
			var calTD = document.createElement('td');
			if (j == 0 || j == 6 )
				calTD.style.backgroundColor = '#fff';
			if ((i==0 && j < dayNo) || dayCount > monthNo) // if this is the first row....
				calTDtext = document.createElement('br');
			else  {
				calTDtext = document.createTextNode(dayCount.toString());
				
				if (dayCount == curr_dy && m == curr_mn && y == curr_yr)
					calTD.style.color = '#ff6600';
				dayCount++;
			}
			calTD.appendChild(calTDtext);
			calTD.setAttribute('width','14%');
			calTR.appendChild(calTD);
		}
		calTB.appendChild(calTR);
	}
	
	var nMonth = getNextMonth(m,y,+1);
	var pMonth = getNextMonth(m,y,-1);
	
	document.getElementById('pyNav').innerHTML = '<a href="javascript:void(0)" title="Previous Year" onclick="buildCalendar('+m+','+(y-1)+',\''+ff+'\')"><<</a>';
	document.getElementById('pmNav').innerHTML = '<a href="javascript:void(0)" title="Previous Month" onclick="buildCalendar('+pMonth[0]+','+pMonth[1]+')"><</a>';
	document.getElementById('myNav').innerHTML = moty[m] +' '+y;
	document.getElementById('nyNav').innerHTML = '<a href="javascript:void(0)" title="Next Year" onclick="buildCalendar('+m+','+(y+1)+')">>></a>';
	document.getElementById('nmNav').innerHTML = '<a href="javascript:void(0)" title="Next Month" onclick="buildCalendar('+nMonth[0]+','+nMonth[1]+')">></a>';
}