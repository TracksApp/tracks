/* protoload 0.1 beta by Andreas Kalsch
 * last change: 09.07.2007
 *
 * This simple piece of code automates the creating of Ajax loading symbols.
 * The loading symbol covers an HTML element with correct position and size - example:
 * $('myElement').startWaiting() and $('myElement').stopWaiting()
 */
 
Protoload = {
	// the script to wait this amount of msecs until it shows the loading element
	timeUntilShow: 250,
	
	// opacity of loading element
	opacity: 0.8,

	// Start waiting status - show loading element
	startWaiting: function(element, className, timeUntilShow) {
		if (typeof element == 'string')
			element = document.getElementById(element);
		if (className == undefined)
			className = 'tracks__waiting';
		if (timeUntilShow == undefined)
			timeUntilShow = Protoload.timeUntilShow;
		
		element._waiting = true;
		if (!element._loading) {
			var e = document.createElement('div');
			(element.offsetParent || document.body).appendChild(element._loading = e);
			e.style.position = 'absolute';
			try {e.style.opacity = Protoload.opacity;} catch(e) {}
			try {e.style.MozOpacity = Protoload.opacity;} catch(e) {}
			try {e.style.filter = 'alpha(opacity='+Math.round(Protoload.opacity * 100)+')';} catch(e) {}
			try {e.style.KhtmlOpacity = Protoload.opacity;} catch(e) {}
			
			/*var zIndex = 0;
			if (window.UI)
				if (UI.zIndex)
					zIndex = ++UI.zIndex;
			if (!zIndex)
				zIndex = ++Protoload._zIndex;
			e.style.zIndex = zIndex;*/
		}
		element._loading.className = className;
		window.setTimeout((function() {
			if (this._waiting) {
				var left = this.offsetLeft, 
					top = this.offsetTop,
					width = this.offsetWidth,
					height = this.offsetHeight,
					l = this._loading;
					
				l.style.left = left+'px';
				l.style.top = top+'px';
				l.style.width = width+'px';
				l.style.height = height+'px';
				l.style.display = 'inline';
			}
		}).bind(element), timeUntilShow);
	},
	
	// Get current waiting status
	isWaiting: function(element) {
	  return element._waiting == true;
	},
	
	// Stop waiting status - hide loading element
	stopWaiting: function(element) {
		if (element._waiting) {
			element._waiting = false;
			element._loading.parentNode.removeChild(element._loading);
			element._loading = null;
		}
	}/*,
	
	_zIndex: 1000000*/
};

if (Prototype) {
	Element.addMethods(Protoload);
	Object.extend(Element, Protoload);
}
/* */