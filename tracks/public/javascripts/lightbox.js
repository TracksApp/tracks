/*--------------------------------------------------------------------------*/
/*	Lightbox	
*	This is a script for creating modal dialog windows (like the ones your operating
*	system uses)
*	
*/

var Lightbox = {
	/* hideAll - closes all open lightbox windows */
	hideAll: function(){
		lboxes = document.getElementsByClassName('lbox')
		lboxes.each(function(box){
				Element.hide(box)
			}
		)
		if ($('overlay')){
			Element.remove('overlay');
			}
	}
}
Lightbox.base = Class.create();
Lightbox.base.prototype = {

	initialize: function(element, options){
		//start by hiding all lightboxes
		Lightbox.hideAll();
	
		this.element = $(element);
		this.options = Object.extend({
			lightboxClassName : 'lightbox',
			closeOnOverlayClick : false,
			externalControl : false
		}, options || {} )

		//create the overlay
		new Insertion.Before(this.element, "<div id='overlay' style='display:none;'></div>");
		
Element.addClassName(this.element, this.options.lightboxClassName)
	
		//also add a default lbox class to the lightbox div so we can find and close all lightboxes if we need to
		Element.addClassName(this.element, 'lbox')
		
		//Tip: make sure the path to the close.gif image below is correct for your setup
		closer = '<img id="close" src="/images/close.gif" alt="Close" title="Close this window" />'

		//insert the closer image into the div
		new Insertion.Top(this.element, closer);
		
		Event.observe($('close'), 'click', this.hideBox.bindAsEventListener(this) );
		
		if (this.options.closeOnOverlayClick){
			Event.observe($('overlay'), 'click', this.hideBox.bindAsEventListener(this) );
		}
		if (this.options.externalControl){
			Event.observe($(this.options.externalControl), 'click', this.hideBox.bindAsEventListener(this) );
		}
				
		this.showBox();	
	},
	
	showBox : function(){
		//show the overlay
	   Element.show('overlay');

		//center the lightbox
	   this.center();
	   
	   	//show the lightbox
	   Element.show(this.element);
	   return false;
	},
	
	hideBox : function(evt){	
		Element.removeClassName(this.element, this.options.lightboxClassName)
		Element.hide(this.element);
		//remove the overlay element from the DOM completely
		Element.remove('overlay');
		return false;
	},
		
	center : function(){
		var my_width  = 0;
		var my_height = 0;
		
		if ( typeof( window.innerWidth ) == 'number' ){
			my_width  = window.innerWidth;
			my_height = window.innerHeight;
		}else if ( document.documentElement && 
				 ( document.documentElement.clientWidth ||
				   document.documentElement.clientHeight ) ){
			my_width  = document.documentElement.clientWidth;
			my_height = document.documentElement.clientHeight;
		}
		else if ( document.body && 
				( document.body.clientWidth || document.body.clientHeight ) ){
			my_width  = document.body.clientWidth;
			my_height = document.body.clientHeight;
		}
		
		this.element.style.position = 'absolute';
		this.element.style.zIndex   = 99;
		
		var scrollY = 0;
		
		if ( document.documentElement && document.documentElement.scrollTop ){
			scrollY = document.documentElement.scrollTop;
		}else if ( document.body && document.body.scrollTop ){
			scrollY = document.body.scrollTop;
		}else if ( window.pageYOffset ){
			scrollY = window.pageYOffset;
		}else if ( window.scrollY ){
			scrollY = window.scrollY;
		}
		
		var elementDimensions = Element.getDimensions(this.element);
		
		var setX = ( my_width  - elementDimensions.width  ) / 2;
		var setY = ( my_height - elementDimensions.height ) / 2 + scrollY;
		
		setX = ( setX < 0 ) ? 0 : setX;
		setY = ( setY < 0 ) ? 0 : setY;
		
		this.element.style.left = setX + "px";
		this.element.style.top  = setY + "px";
		
	}

	
}

