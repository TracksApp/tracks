function toggleAll(itemname,state) {
  tmp = document.getElementsByTagName('div');
  for (i=0;i<tmp.length;i++) {
    if (tmp[i].className == itemname) tmp[i].style.display = state;
  }
}

// Contributed by Andrew Williams
function toggleSingle(idname) 
{
document.getElementById(idname).style.display = (document.getElementById(idname).style.display == 'none') ? 'block' : 'none';
}

function toggleAllImages()
{
  var cookies = document.cookie.split(';');

  for(var i = 0; i < cookies.length; i++)
  {
    var str = cookies[i].split('=')[0];

    if(str.indexOf('toggle_context_') != -1)
    {
      var id = str.split('_')[2];
      if(getCookie(str) == 'collapsed')
      {
        toggleSingle('c'+id);
        toggleImage('toggle_context_'+id);
      }
    }
  }
}

function toggleImage(idname)
{
  if(document.images)
  {
    if(document[idname].src.indexOf('collapse.png') != -1)
    {
      document[idname].src = '/images/expand.png';
      SetCookie(idname, "collapsed");
    }
    else
    {
      document[idname].src = '/images/collapse.png';
      SetCookie(idname, "expanded");
    }
  }
}

function SetCookie (name, value) {
  var argv = SetCookie.arguments;
  var argc = SetCookie.arguments.length;
  var expires = (argc > 2) ? argv[2] : null;
  var path = (argc > 3) ? argv[3] : null;
  var domain = (argc > 4) ? argv[4] : null;
  var secure = (argc > 5) ? argv[5] : false;
  document.cookie = name + "=" + escape (value) +
  ((expires == null) ? "" : ("; expires=" +
  expires.toGMTString())) +
  ((path == null) ? "" : ("; path=" + path)) +
  ((domain == null) ? "" : ("; domain=" + domain)) +
  ((secure == true) ? "; secure" : "");
}

var bikky = document.cookie;

  function getCookie(name) { // use: getCookie("name");
    var index = bikky.indexOf(name + "=");
    if (index == -1) return null;
    index = bikky.indexOf("=", index) + 1; // first character
    var endstr = bikky.indexOf(";", index);
    if (endstr == -1) endstr = bikky.length; // last character
    return unescape(bikky.substring(index, endstr));
  }
  

//
// XMLHTTPRequest code from David Goodlad <http://hieraki.goodlad.ca/read/book/1>
//

function createXMLHttpRequest() {
  try {
    // Attempt to create it "the Mozilla way" 
    if (window.XMLHttpRequest) {
      return new XMLHttpRequest();
    }
    // Guess not - now the IE way
    if (window.ActiveXObject) {
      return new ActiveXObject(getXMLPrefix() + ".XmlHttp");
    }
  }
  catch (ex) {}
  return false;
};

// Move item from uncompleted to completed
// Many thanks to Michelle at PXL8 for a great tutorial:
// <http://www.pxl8.com/appendChild.html>
function moveRow(id){
  // -- get the table row correstponding to the selected item
  var m1 = document.getElementById(id);
  if (m1)
  // -- append it to the 1st tbody of table id="holding"
  document.getElementById('holding').getElementsByTagName('tbody')[0].appendChild(m1);
}

function markItemDone(rowId, uri, id) {
  var req = createXMLHttpRequest();
  moveRow(rowId);

  if(!req) {
    return false;
  }

  req.open("POST", uri, true); //POST asynchronously
  req.setRequestHeader('Content-Type', 'application/x-www-form-url-encoded; charset=UTF-8');
  req.onreadystatechange = function() {
    if (req.readyState == 4 && req.status == 200) {
    }
  }
  req.send(encodeURIComponent("id") + '=' + encodeURIComponent(id));
};

