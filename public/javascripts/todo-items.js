/*
 * ToDo Items
 *
 *  Requires the prototype.js library
 *
 *  Use the following markup to include the library:
 *  <script type="text/javascript" src="todo-items.js"></script>
 */

ToDoItems = Class.create();

ToDoItems.prototype = {
    initialize: function()
    {
        /* keep track of last effect so you can check if the animation has finised */
        this.lastEffect= null;
        this.initialized = true;
        this.contextCollapseCookieManager = new CookieManager();
        this.toggleItemsMap = {};
        this.toggleContainerMap = {};
        this.containerItemsMap = {};
    },
    addNextActionListingToggles: function()
    {
        this.containerToggles = $$('.container_toggle');
        containerTogglesClick = this.toggleNextActionListing.bindAsEventListener(this);
        for(i=0; i < this.containerToggles.length; i++)
        {
            toggleElem = this.containerToggles[i];
            containerElem = toggleElem.parentNode.parentNode
            itemsElem = $(containerElem.id).select("div#"+containerElem.id+"items")[0];
            this.toggleContainerMap[toggleElem.id] = containerElem;
            this.toggleItemsMap[toggleElem.id] = itemsElem;
            this.containerItemsMap[containerElem.id] = itemsElem;
        }
	this.setNextActionListingTogglesToCookiedState();
    },
    setNextActionListingTogglesToCookiedState: function()
    {
        for(i=0; i < this.containerToggles.length; i++)
        {
            toggleElem = this.containerToggles[i];
            containerElem = this.toggleContainerMap[toggleElem.id];
            collapsedCookie = this.contextCollapseCookieManager.getCookie(this.buildCookieName(containerElem));
            itemsElem = this.toggleItemsMap[toggleElem.id];
            isExpanded = Element.visible(itemsElem);
            if (collapsedCookie && isExpanded)
            {
                this.collapseNextActionListing(toggleElem, itemsElem);
            }
            else if (!collapsedCookie && !isExpanded)
            {
                this.expandNextActionListing(toggleElem, itemsElem);
            }
        }
    },
    collapseAllNextActionListing: function(except)
    {
        for(i=0; i < this.containerToggles.length; i++)
        {
            toggleElem = this.containerToggles[i];
            if (toggleElem != except)
            {
                itemsElem = this.toggleItemsMap[toggleElem.id];
                isExpanded = Element.visible(itemsElem);
                if (isExpanded)
                {
                    this.collapseNextActionListing(toggleElem, itemsElem);
                }
            }
        }
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
        toggleElem = Event.element(event).parentNode;
        itemsElem = this.toggleItemsMap[toggleElem.id];
   	containerElem = this.toggleContainerMap[toggleElem.id];
        if (Element.visible(itemsElem))
        {
            this.collapseNextActionListing(toggleElem, itemsElem);
            this.contextCollapseCookieManager.setCookie(this.buildCookieName(containerElem), true)
        }
        else
        {
            this.expandNextActionListing(toggleElem, itemsElem);
            this.contextCollapseCookieManager.clearCookie(this.buildCookieName(containerElem))
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
            this.lastEffect = Effect.BlindDown(itemsElem, { duration: 0.4 });
        }
        toggleElem.setAttribute('title', 'Collapse');
        imgElem = this.findToggleImgElem(toggleElem);
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
        contextElem = this.findNearestParentByClassName($(itemsElem), "context");
        toggleElem = this.findToggleElemForContext(contextElem);
        this.expandNextActionListing(toggleElem, itemsElem, skipAnimation);
    },
    collapseNextActionListing: function(toggleElem, itemsElem)
    {
        this.lastEffect = Effect.BlindUp(itemsElem, { duration: 0.4});
        toggleElem.setAttribute('title', 'Expand');
        imgElem = this.findToggleImgElem(toggleElem);
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
   	tracks_login = this.contextCollapseCookieManager.getCookie('tracks_login');
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
    }
}

todoItems = new ToDoItems();
Event.observe(window, "load", todoItems.addNextActionListingToggles.bindAsEventListener(todoItems));
