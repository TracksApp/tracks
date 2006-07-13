/************************************
 *
 * An add-on to Prototype 1.5 to speed up the $$ function in usual cases.
 *
 * http://www.sylvainzimmer.com/index.php/archives/2006/06/25/speeding-up-prototypes-selector/
 * 
 * Authors: 
 *    - Sylvain ZIMMER <sylvain _at_ jamendo.com>
 *
 * Changelog:
 *   v1 (2006/06/25)
 *     - Initial release
 *
 * License: AS-IS
 *
 * Trivia: Check out www.jamendo.com for some great Creative Commons music ;-)
 *
 ************************************/
 
 
 
// We don't extend the Selector class because we want 
// to be able to use it if the expression is too complicated.
var SelectorLiteAddon=Class.create();


SelectorLiteAddon.prototype = {

  // This is the constructor. It parses the stack of selectors.
  initialize: function(stack) {
    
    this.r=[]; //results
    this.s=[]; //stack of selectors
    this.i=0;  //stack pointer
    
    //Parse the selectors
    for (var i=stack.length-1;i>=0;i--) {
    
      //This is the parsed selector. Format is : [tagname, id, classnames]
      var s=["*","",[]]; 
      
      //The unparsed current selector
      var t=stack[i];
      
      //Parse the selector backwards
      var cursor=t.length-1;
      do {
        
        var d=t.lastIndexOf("#");
        var p=t.lastIndexOf(".");
        cursor=Math.max(d,p);
        
        //Found a tagName
        if (cursor==-1) {
          s[0]=t.toUpperCase();
          
        //Found a className
        } else if (d==-1 || p==cursor) {
          s[2].push(t.substring(p+1));
          
        //Found an ID
        } else if (!s[1]) {
          s[1]=t.substring(d+1);
        }
        t=t.substring(0,cursor);
      } while (cursor>0);
      this.s[i]=s;
    }
  },
  
  //Returns a list of matched elements below a given root.
  get:function(root) {
    this.explore(root || document,this.i==(this.s.length-1));
    return this.r;
  },
  
  //Recursive function where the actual search is being done.
  // elt: current root element
  // leaf: boolean, are we in a leaf of the search tree?
  explore:function(elt,leaf) {
    
    //Parsed selector
    var s=this.s[this.i];
    
    //Results
    var r=[];
    
    //Selector has an ID, use it!
    if (s[1]) {
    
      e=$(s[1]);      
      if (e && (s[0]=="*" || e.tagName==s[0]) && e.childOf(elt)) {
       r=[e];
      }
      
    //Selector has no ID, search by tagname.
    } else {
      r=$A(elt.getElementsByTagName(s[0]));
    }
    
    
    //Filter the results by classnames. 
    //Todo: by attributes too?
    //Sidenote: The performance hit is often here.
    
    //Single className : that's fast!
    if (s[2].length==1) { //single classname
      r=r.findAll(function(o) {
      
        //If the element has only one classname too, the test is simple!
        if (o.className.indexOf(" ")==-1) {
          return o.className==s[2][0];
        } else {
          return o.className.split(/\s+/).include(s[2][0]);
        }
      });
    
    //Multipe classNames, a bit slower.
    } else if (s[2].length>0) {
      r=r.findAll(function(o) {
      
        //If the elemtn has only one classname, we can drop it.
        if (o.className.indexOf(" ")==-1) { 
          return false;
        } else {
        
          //Check that all required classnames are present.
          var q=o.className.split(/\s+/);
          return s[2].all(function(c) {
            return q.include(c);
          });
        }
      });
    }
    
    
    //Append the results if we're in a leaf
    if (leaf) {
      this.r=this.r.concat(r);
      
    //Continue exploring the tree otherwise
    } else {
      ++this.i;
      r.each(function(o) {
        this.explore(o,this.i==(this.s.length-1));
      }.bind(this));
    }
  }
  
}


//Overwrite the $$ function.
var $$old=$$;

var $$=function(a,b) {

  //expression is too complicated, forward the call to prototype's function!
  if (b || a.indexOf("[")>=0) return $$old.apply(this,arguments);
  
  //Otherwise use our addon!
  return new SelectorLiteAddon(a.split(/\s+/)).get();
}
