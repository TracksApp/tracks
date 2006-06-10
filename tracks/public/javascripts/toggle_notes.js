function toggleAll(className) {
  var elems = document.getElementsByClassName(className);
  for (var i = 0; i < elems.length; i++) {
    if (elems[i].style.display == 'block') 
    {
      elems[i].style.display = 'none';
    } 
    else
    {
      elems[i].style.display = 'block';
    }
  }
}