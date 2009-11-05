/*
 * AccessKey Hints
 *
 * Checks all HTML elements on this page that can have an accesskey attribute
 * (<a>, <area>, <button>, <input>, <label>, <legend> and <textarea>)
 * and creates or appends the title attribute to include platform-specific
 * hint in the title, i.e. "Alt+S" (Win)
 * or "Ctrl+S)" (Mac). If a title exists, a space plus the hint wrapped in
 * parentheses is appended. The only exception is if the title already contains
 * 'accesskey', 'Alt+' or 'Ctrl+' (case-insensitive) in which case this script
 * will leave it alone.
 *
 *  Use the following markup to include the library:
 *  <script type="text/javascript" src="access-key-hints.js"></script>
 */
var accessKeyHintsAdder = {
	
	run : function() {
	  var elemTypes = new Array('a','area','button','input','label','legend','textarea');
	  for(var i = 0; i < elemTypes.length; i++)
	  {
	    accessKeyHintsAdder.addHint(document.getElementsByTagName(elemTypes[i]));
	  }
	},
	
	addHint : function(elems) {
	  var elem;
	  var i = 0;

	  processElements:
	  while(elem = elems.item(i++))
	  {
	    var accessKey = elem.getAttributeNode("accesskey");
	    if (!accessKey || !accessKey.value)
	      continue processElements;

	    var title = elem.getAttributeNode("title");
	    if (title && title.value)
	    {
	      var overrides = new Array('accesskey','alt+','ctrl+');
	      for (var j=0; j < overrides.length; j++)
	      {
	        if (title.value.toLowerCase().indexOf(overrides[j]) != -1)
	          continue processElements;
	      }
	      elem.setAttribute("title", title.value + ' (' + this.getHintText(accessKey.value) + ')');
	    }
	    else
	    {
	        elem.setAttribute("title", this.getHintText(accessKey.value));
	    }
	  }
	},
	
	getHintText : function(accessKey) {
        return this.getModifier() + '+' + accessKey.toUpperCase();
	},
	
	getModifier : function() {
	   var ua = navigator.userAgent.toLowerCase(); 
	   if (ua.indexOf('mac') == -1)
	     return 'Alt';
	   else
	     return 'Ctrl';
	}
	
}

$(accessKeyHintsAdder.run);
