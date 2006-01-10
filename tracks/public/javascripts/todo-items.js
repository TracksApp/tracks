/*
 * ToDo Items
 *
 *  Requires the prototype.js library
 *
 *  Use the following markup to include the library:
 *  <script type="text/javascript" src="todo-items.js"></script>
 */

addEvent(window, "load", addNextActionListingToggles);

function addNextActionListingToggles()
{
  var toggleElems = document.getElementsByClassName('container_toggle');
  for(var i = 0; i < toggleElems.length; i++)
  {
    addEvent(toggleElems[i], "click", toggleNextActionListing);
  }
}

function ensureVisibleWithEffectAppear(elemId)
{
	if ($(elemId).style.display == 'none')
	{
		new Effect.Appear(elemId,{duration:0.4});
	}
}	

function fadeAndRemoveItem(itemContainerElemId)
{
	var fadingElemId = itemContainerElemId + '-fading';
	$(itemContainerElemId).setAttribute('id',fadingElemId);
	Element.removeClassName($(fadingElemId),'item-container');
	new Effect.Fade(fadingElemId,{afterFinish:function(effect) { Element.remove(fadingElemId); }, duration:0.4});
}

function toggleNextActionListing()
{
  var itemsElem = findItemsElem(this);
  if (Element.visible(itemsElem))
    Effect.BlindUp(itemsElem, { duration: 0.4});
  else
    Effect.BlindDown(itemsElem, { duration: 0.4 });
  this.setAttribute('title', (this.style.display == 'none') ? 'Expand' : 'Collapse');
  var childImgElems = this.getElementsByTagName('img');
  for(var i = 0; i < childImgElems.length; i++)
  {
	 if (childImgElems[i].src.indexOf('collapse.png') != -1)
    {
	   	childImgElems[i].src = childImgElems[i].src.replace('collapse','expand');
	   	childImgElems[i].setAttribute('title','Expand');
	      //SetCookie(idname, "collapsed");
    }
	 else if (childImgElems[i].src.indexOf('expand.png') != -1)
	 {
	   	childImgElems[i].src = childImgElems[i].src.replace('expand','collapse');
	   	childImgElems[i].setAttribute('title','Collapse');
	      //SetCookie(idname, "expanded");
	 }
  }
  return false;
}

function findNearestParentByClassName(elem, parentClassName)
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

function findItemsElem(toggleElem)
{
	var containerElem = findNearestParentByClassName(toggleElem, "container");
	if (containerElem)
		return document.getElementsByClassName('toggle_target',containerElem)[0];
	else
		return null;
}

// This is a cross-browser function for event addition.
function addEvent(obj, evType, fn)
{
  if (obj.addEventListener)
  {
    obj.addEventListener(evType, fn, false);
    return true;
  }
  else if (obj.attachEvent)
  {
    var r = obj.attachEvent("on" + evType, fn);
    return r;
  }
  else
  {
    alert("Event handler could not be attached");
    return false;
  }
}

function removeEvent(obj, evType, fn)
{
  if (obj.removeEventListener)
  {
    obj.removeEventListener(evType, fn, false);
    return true;
  }
  else if (obj.detachEvent)
  {
    var r = obj.detachEvent("on"+evType, fn);
    return r;
  }
  else
  {
    alert("Handler could not be removed");
  }
}