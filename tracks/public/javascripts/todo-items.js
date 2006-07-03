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
    $$('.container_toggle').each(function(toggleElem){
      Event.observe(toggleElem, 'click', todoItems.toggleNextActionListing);
      toggleElem.onclick = function() {return false;}; //workaround for Event.stop problem with Safari 2.0.3. See http://particletree.com/notebook/eventstop/
		});
	  todoItems.setNextActionListingTogglesToCookiedState();
  },
  setNextActionListingTogglesToCookiedState: function()
  {
    contextCollapseCookieManager = new CookieManager();
    $$('.container_toggle').each(function(toggleElem){
      containerElem = todoItems.findNearestParentByClassName(toggleElem, "container");
      collapsedCookie = contextCollapseCookieManager.getCookie(todoItems.buildCookieName(containerElem));
      itemsElem = todoItems.findItemsElem(toggleElem);
      isExpanded = Element.visible(itemsElem);
      if (collapsedCookie && isExpanded)
      {
        todoItems.collapseNextActionListing(toggleElem, itemsElem);
      }
      else if (!collapsedCookie && !isExpanded)
      {
        todoItems.expandNextActionListing(toggleElem, itemsElem);
      }
		});
  },
  collapseAllNextActionListing: function(except)
  {
    $$('.container_toggle').each(function(toggleElem){
      if (toggleElem != except)
      itemsElem = todoItems.findItemsElem(toggleElem);
      isExpanded = Element.visible(itemsElem);
      if (isExpanded)
      {
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

  toggleNextActionListing: function(event)
  {
    Event.stop(event);
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
  },
  findToggleElemForContext : function(contextElem)
  {
    childElems = $A($(contextElem).getElementsByTagName('a'));
    return childElems.detect(function(childElem) { return childElem.className == 'container_toggle' });
  },
  expandNextActionListing: function(toggleElem, itemsElem, skipAnimation)
  {
    itemsElem = $(itemsElem)
    if (skipAnimation == true) {
      itemsElem.style.display = 'block';
    }
    else
    {
      Effect.BlindDown(itemsElem, { duration: 0.4 });
    }
    toggleElem.setAttribute('title', 'Collapse');
    imgElem = todoItems.findToggleImgElem(toggleElem);
  	imgElem.src = imgElem.src.replace('expand','collapse');
    imgElem.setAttribute('title','Collapse');
  },
  ensureContainerHeight: function(itemsElem)
  {
    itemsElem = $(itemsElem);
    Element.setStyle(itemsElem, {height : ''});
    Element.setStyle(itemsElem, {overflow : ''});
  },
  expandNextActionListingByContext: function(itemsElem, skipAnimation)
  {
    contextElem = todoItems.findNearestParentByClassName($(itemsElem), "context");
    toggleElem = todoItems.findToggleElemForContext(contextElem);
    todoItems.expandNextActionListing(toggleElem, itemsElem, skipAnimation);
  },
  collapseNextActionListing: function(toggleElem, itemsElem)
  {
    Effect.BlindUp(itemsElem, { duration: 0.4});
    toggleElem.setAttribute('title', 'Expand');
    imgElem = todoItems.findToggleImgElem(toggleElem);
   	imgElem.src = imgElem.src.replace('collapse','expand');
   	imgElem.setAttribute('title','Expand');
  },
  findToggleImgElem: function(toggleElem)
  {
    childImgElems = $A(toggleElem.getElementsByTagName('img'));
    return childImgElems[0];
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
  },
  
  addItemDragDrop: function()
  {    
    $$('.item-container').each(function(containerElem){
      todoItems.makeItemDraggable(containerElem);
    });
    $$('.context').each(function(contextElem){
      todoItems.makeContextDroppable(contextElem);
    });
  },
  makeItemDraggable: function(itemContainerElem)
  {
    new Draggable($(itemContainerElem).id,
    {
	    handle:'description',
		  starteffect:todoItems.startDraggingItem,
		  endeffect:todoItems.stopDraggingItem,
	    revert:true
    });
  },
  makeContextDroppable: function(contextElem)
  {
	  Droppables.add($(contextElem).id,
	  {
		  accept:'item-container',
		  hoverclass:'item-container-drop-target',
		  onDrop: todoItems.itemDrop,
		  zindex: 1000
    });
  },
  startDraggingItem:function(draggable)
  {
    parentContainer = todoItems.findNearestParentByClassName(draggable, 'container');
    draggable.parentContainer = parentContainer;
    toggleElem = document.getElementsByClassName('container_toggle',parentContainer)[0];
    todoItems.collapseAllNextActionListing(toggleElem);
  },
  stopDraggingItem:function(draggable)
  {
    todoItems.setNextActionListingTogglesToCookiedState();
  },
  
  itemDrop:function(draggableElement, droppableElement) {
    if (draggableElement.parentContainer == droppableElement) {
      return; //same destination as original, nothing to be done
    } 
    itemElementId = draggableElement.id
    todoId = draggableElement.id.match(/\d+/)[0];
    contextId = droppableElement.id.match(/\d+/)[0];
    Draggables.drags.each(function(drag) {
      if (drag.element == draggableElement) {
        drag.destroy();
      }
    })
    new Ajax.Request('/todo/update_context', {
      asynchronous:true,
      evalScripts:true,
      parameters:"id=" + todoId + "&context_id=" + contextId
    })
  }
}
Event.observe(window, "load", todoItems.addNextActionListingToggles);
Event.observe(window, "load", todoItems.addItemDragDrop);
