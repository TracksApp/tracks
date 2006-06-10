/*
 * ToDo Items
 *
 *  Requires the prototype.js library
 *
 *  Use the following markup to include the library:
 *  <script type="text/javascript" src="todo-items.js"></script>
 */

var todoItems = {

  addNextActionListingToggles: function()
  {
    this.contextCollapseCookieManager = new CookieManager();
    var toggleElems = document.getElementsByClassName('container_toggle');
    toggleElems.each(function(toggleElem){
      Event.observe(toggleElem, 'click', todoItems.toggleNextActionListing);
      containerElem = todoItems.findNearestParentByClassName(toggleElem, "container");
      collapsedCookie = contextCollapseCookieManager.getCookie(todoItems.buildCookieName(containerElem));
      if (collapsedCookie)
      {
        itemsElem = todoItems.findItemsElem(toggleElem);
        todoItems.collapseNextActionListing(toggleElem, itemsElem);
      }
		});
  },

  ensureVisibleWithEffectAppear: function(elemId)
  {
  	if ($(elemId).style.display == 'none')
  	{
  		new Effect.Appear(elemId,{duration:0.4});
  	}
  },

  fadeAndRemoveItem: function(itemContainerElemId)
  {
  	var fadingElemId = itemContainerElemId + '-fading';
  	$(itemContainerElemId).setAttribute('id',fadingElemId);
  	Element.removeClassName($(fadingElemId),'item-container');
  	new Effect.Fade(fadingElemId,{afterFinish:function(effect) { Element.remove(fadingElemId); }, duration:0.4});
  },

  toggleNextActionListing: function()
  {
    itemsElem = todoItems.findItemsElem(this);
   	containerElem = todoItems.findNearestParentByClassName(this, "container");
    if (Element.visible(itemsElem))
    {
      todoItems.collapseNextActionListing(this, itemsElem);
	   	contextCollapseCookieManager.setCookie(todoItems.buildCookieName(containerElem), true)
    }
    else
    {
      todoItems.expandNextActionListing(this, itemsElem);
	   	contextCollapseCookieManager.clearCookie(todoItems.buildCookieName(containerElem))
    }
    return false;
  },
  
  expandNextActionListing: function(toggleElem, itemsElem)
  {
    Effect.BlindDown(itemsElem, { duration: 0.4 });
    toggleElem.setAttribute('title', 'Collapse');
    imgElem = todoItems.findFirstImgElementWithSrcContaining(toggleElem, 'expand.png');
  	imgElem.src = imgElem.src.replace('expand','collapse');
    imgElem.setAttribute('title','Collapse');
  },
  
  collapseNextActionListing: function(toggleElem, itemsElem)
  {
    Effect.BlindUp(itemsElem, { duration: 0.4});
    toggleElem.setAttribute('title', 'Expand');
    imgElem = todoItems.findFirstImgElementWithSrcContaining(toggleElem, 'collapse.png');
   	imgElem.src = imgElem.src.replace('collapse','expand');
   	imgElem.setAttribute('title','Expand');
  },
  
  findFirstImgElementWithSrcContaining: function(searchRootElem, srcString)
  {
    childImgElems = $A(searchRootElem.getElementsByTagName('img'));
    return childImgElems.detect(function(childImgElem) { return childImgElem.src.indexOf(srcString) != -1 });
  },
  
  buildCookieName: function(containerElem)
  {
   	tracks_login = contextCollapseCookieManager.getCookie('tracks_login');
    return 'tracks_'+tracks_login+'_context_' + containerElem.id + '_collapsed';
  },

  findNearestParentByClassName: function(elem, parentClassName)
  {
  	var parentElem = elem.parentNode;
  	while(parentElem)
  	{
  		if (Element.hasClassName(parentElem, parentClassName))
  		{
  			return parentElem;
  		}
  		parentElem = parentElem.parentNode;
  	}
  	return null;
  },

  findItemsElem : function(toggleElem)
  {
  	var containerElem = todoItems.findNearestParentByClassName(toggleElem, "container");
  	if (containerElem)
  		return document.getElementsByClassName('toggle_target',containerElem)[0];
  	else
  		return null;
  }
}
Event.observe(window, "load", todoItems.addNextActionListingToggles);
