function toggleAll(itemname,state)
{
	tmp = document.getElementsByTagName('div');
  	for (i=0;i<tmp.length;i++)
    	{
       if (tmp[i].className == itemname) tmp[i].style.display = state;
    	}
}

function toggle(idname) 
{
		document.getElementById(idname).style.display = (document.getElementById(idname).style.display == 'none') ? 'block' : 'none';
}