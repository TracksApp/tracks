function toggleAll(className) {
  document.getElementsByClassName(className).each(function(elem){
    if (elem.style.display == 'block') 
    {
      elem.style.display = 'none';
    } 
    else
    {
      elem.style.display = 'block';
    }
  });
}