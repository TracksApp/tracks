function toggleAll(itemname,state) {
  tmp = document.getElementsByTagName('div');
  for (i=0;i<tmp.length;i++) {
    if (tmp[i].className == itemname) tmp[i].style.display = state;
  }
}

function toggle(idname) {
  document.getElementById(idname).style.display = (document.getElementById(idname).style.display == 'none') ? 'block' : 'none';
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
