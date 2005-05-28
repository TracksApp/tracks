/* Form extensions - prototype-ex by Matt McCray
  <http://darthapo.com/repos/prototype-ex.html> */

Form.extend( {

   disable: function( form ) {
      var elements = Form.getElements( form );
      for(var i=0; i<elements.length; i++)
      {
         elements[i].blur();
         elements[i].disable = 'true';
      }
   },

   focus_first: function( form )
   {
      form = $(form);
      var elements = Form.getElements( form );
      for( var i=0; i<elements.length; i++ ) {
         var elem = elements[i];
         if( elem.type != 'hidden' && !elem.disabled) {
            Field.activate( elem );
            break;
         }
      }
   },

   reset: function( form )
   {
      $(form).reset();
   }
   
});

/*--------------------------------------------------------------------------*/

Field.extend({

   select: function(element) {
      $(element).select();
   },
   
   activate: function(element) {
      $(element).focus();
      $(element).select();
   }
   
});

var Action = {
  do_submit: function(form) {
     // calling form.submit seems to override the onsubmit handler...
     $(form).onsubmit();
  },
};