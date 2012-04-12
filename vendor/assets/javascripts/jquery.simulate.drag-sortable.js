(function($) {
  /*
   * Simulate drag of a JQuery UI sortable list
   * Repository: https://github.com/mattheworiordan/jquery.simulate.drag-sortable.js
   * Author: http://mattheworiordan.com
   *
   * options are:
   * - move: move item up (positive) or down (negative) by Integer amount
   * - handle: selector for the draggable handle element (optional)
   * - listItem: selector to limit which sibling items can be used for reordering
   * - placeHolder: if a placeholder is used during dragging, we need to consider it's height
   *
   */
  $.fn.simulateDragSortable = function(options) {
    // build main options before element iteration
    var opts = $.extend({}, $.fn.simulateDragSortable.defaults, options);

    // iterate and move each matched element
    return this.each(function() {
      // allow for a drag handle if item is not draggable
      var that = this,
          handle = opts.handle ? $(this).find(opts.handle)[0] : $(this)[0],
          listItem = opts.listItem,
          placeHolder = opts.placeHolder,
          sibling = $(this),
          moveCounter = Math.floor(opts.move),
          direction = moveCounter > 0 ? 'down' : 'up',
          moveVerticalAmount = 0,
          dragPastBy = 0;
          
      if (moveCounter === 0) { return; }

      while (moveCounter !== 0) {
        if (direction === 'down') {
          if (sibling.next(listItem).length) {
            sibling = sibling.next(listItem);
            moveVerticalAmount += sibling.outerHeight();
          }
          moveCounter -= 1;
        } else {
          if (sibling.prev(listItem).length) {
            sibling = sibling.prev(listItem);
            moveVerticalAmount -= sibling.outerHeight();
          }
          moveCounter += 1;
        }
      }

      var center = findCenter(handle);
      var x = Math.floor(center.x), y = Math.floor(center.y);
      dispatchEvent(handle, 'mousedown', createEvent('mousedown', handle, { clientX: x, clientY: y }));
      // simulate drag start
      dispatchEvent(document, 'mousemove', createEvent('mousemove', document, { clientX: x+1, clientY: y+1 }));

      // Sortable is using a fixed height placeholder meaning items jump up and down as you drag variable height items into fixed height placeholder
      placeHolder = placeHolder && $(this).parent().find(placeHolder);
      if (placeHolder && placeHolder.length) {
        // we're going to move past it, and back again
        moveVerticalAmount += (direction === 'down' ? -1 : 1) * Math.min($(this).outerHeight() / 2, 5);
        // Sortable UI bug when dragging down and place holder exists.  You need to drag past by the total height of this
        //  and then drag back to the right point
        dragPastBy = (direction === 'down' ? 1 : -1) * $(this).outerHeight() / 2;
      } else {
        // no place holder
        if (direction === 'down') {
          // need to move at least as far as this item and or the last sibling
          if ($(this).outerHeight() > $(sibling).outerHeight()) {
            moveVerticalAmount += $(this).outerHeight() - $(sibling).outerHeight();
          }
          moveVerticalAmount += $(sibling).outerHeight() / 2;
        } else {
          // move a little extra to ensure item clips into next position
          moveVerticalAmount -= Math.min($(this).outerHeight() / 2, 5);
        }
      }

      if (sibling[0] !== $(this)[0]) {
        // step through so that the UI controller can determine when to show the placeHolder
        var targetOffset = moveVerticalAmount + dragPastBy;
        for (var offset = 0; Math.abs(offset) < Math.abs(targetOffset); offset += (direction === 'down' ? 10 : -10)) {
          // drag move
          dispatchEvent(document, 'mousemove', createEvent('mousemove', document, { clientX: x, clientY: y + offset }));
        }
        dispatchEvent(document, 'mousemove', createEvent('mousemove', document, { clientX: x, clientY: y + targetOffset }));
      } else {
        if (window.console) {
          console.log('Could not move as at top or bottom already');
        }
      }

      setTimeout(function() {
        dispatchEvent(document, 'mousemove', createEvent('mousemove', document, { clientX: x, clientY: y + moveVerticalAmount }));
      }, 5);
      setTimeout(function() {
        dispatchEvent(handle, 'mouseup', createEvent('mouseup', handle, { clientX: x, clientY: y + moveVerticalAmount }));
      }, 10);
    });
  };

  function createEvent(type, target, options) {
    var evt;
    var e = $.extend({
      target: target,
      preventDefault: function() { },
      stopImmediatePropagation: function() { },
      stopPropagation: function() { },
      isPropagationStopped: function() { return true; },
      isImmediatePropagationStopped: function() { return true; },
      isDefaultPrevented: function() { return true; },
      bubbles: true,
      cancelable: (type != "mousemove"),
      view: window,
      detail: 0,
      screenX: 0,
      screenY: 0,
      clientX: 0,
      clientY: 0,
      ctrlKey: false,
      altKey: false,
      shiftKey: false,
      metaKey: false,
      button: 0,
      relatedTarget: undefined
    }, options || {});

    if ($.isFunction(document.createEvent)) {
      evt = document.createEvent("MouseEvents");
      evt.initMouseEvent(type, e.bubbles, e.cancelable, e.view, e.detail,
        e.screenX, e.screenY, e.clientX, e.clientY,
        e.ctrlKey, e.altKey, e.shiftKey, e.metaKey,
        e.button, e.relatedTarget || document.body.parentNode);
    } else if (document.createEventObject) {
      evt = document.createEventObject();
      $.extend(evt, e);
        evt.button = { 0:1, 1:4, 2:2 }[evt.button] || evt.button;
    }
    return evt;
  }

  function dispatchEvent(el, type, evt) {
    if (el.dispatchEvent) {
      el.dispatchEvent(evt);
    } else if (el.fireEvent) {
      el.fireEvent('on' + type, evt);
    }
    return evt;
  }

  function findCenter(el) {
    var el = $(el), o = el.offset();
    return {
      x: o.left + el.outerWidth() / 2,
      y: o.top + el.outerHeight() / 2
    };
  }

  //
  // plugin defaults
  //
  $.fn.simulateDragSortable.defaults = {
    move: 0
  };
})(jQuery);