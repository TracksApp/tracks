var TracksForm = {
    toggle: function(toggleDivId, formContainerId, formId, hideLinkText,
                hideLinkTitle, showLinkText, showLinkTitle) {
        $('#'+formContainerId).toggle();
        toggleDiv = $('#'+toggleDivId);
        toggleLink = toggleDiv.find('a');
        if (toggleDiv.hasClass('hide_form')) {
            toggleLink.text(showLinkText).attr('title', showLinkTitle);
        }
        else {
            toggleLink.text(hideLinkText).attr('title', hideLinkTitle);
            $('#'+formId+' input:text:first').focus();
        }
        toggleDiv.toggleClass('hide_form');
    }, 
    hide_all_recurring: function () {
        $('#recurring_daily').hide();
        $('#recurring_weekly').hide();
        $('#recurring_monthly').hide();
        $('#recurring_yearly').hide();
    },
    hide_all_edit_recurring: function () {
        $('#recurring_edit_daily').hide();
        $('#recurring_edit_weekly').hide();
        $('#recurring_edit_monthly').hide();
        $('#recurring_edit_yearly').hide();
    },
    toggle_overlay: function () {
        el = document.getElementById("overlay");
        el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
    }
}

$.fn.clearForm = function() {
  return this.each(function() {
    var type = this.type, tag = this.tagName.toLowerCase();
    if (tag == 'form')
      return $(':input',this).clearForm();
    if (type == 'text' || type == 'password' || tag == 'textarea')
      this.value = '';
    else if (type == 'checkbox' || type == 'radio')
      this.checked = false;
    else if (tag == 'select')
      this.selectedIndex = -1;
  });
};

/****************************************
 * Unobtrusive jQuery written by Eric Allen
 ****************************************/

/* Set up authenticity token properly */
$(document).ajaxSend(function(event, request, settings) {
  if ( settings.type == 'POST' ) {
    if(typeof(AUTH_TOKEN) != 'undefined'){
      settings.data = (settings.data ? settings.data + "&" : "")
        + "authenticity_token=" + encodeURIComponent( AUTH_TOKEN ) + "&"
        + "_source_view=" + encodeURIComponent( SOURCE_VIEW );
    } else {
      settings.data = (settings.data ? settings.data + "&" : "")
        + "_source_view=" + encodeURIComponent( SOURCE_VIEW );
    }
    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  }
  request.setRequestHeader("Accept", "text/javascript");
});

todoItems = {
  // public
  ensureVisibleWithEffectAppear: function(elemId){
    $('#'+elemId).fadeIn(400);
  },
  expandNextActionListing: function(itemsElem, skipAnimation) {
    itemsElem = $(itemsElem);
    if(skipAnimation == true) {
      itemsElem.show();
    }
    else {
      itemsElem.show('blind', 400);
    }
    todoItems.showContainer(itemsElem.parentNode);
  },
  collapseNextActionListing: function(itemsElem, skipAnimation) {
    itemsElem = $(itemsElem);
    if(skipAnimation == true) {
      itemsElem.hide();
    }
    else {
      itemsElem.hide('blind', 400);
    }
    todoItems.hideContainer(itemsElem.parentNode);
  },
  ensureContainerHeight: function(itemsElem) {
    $(itemsElem).css({height: '', overflow: ''});
  },
  expandNextActionListingByContext: function(itemsElemId, skipAnimation){
    todoItems.expandNextActionListing($('#'+itemsElemId).get(), skipAnimation);
  },

  // private
  buildCookieName: function(containerElem) {
    tracks_login = $.cookie('tracks_login');
    return 'tracks_'+tracks_login+'_context_' + containerElem.id + '_collapsed';
  },
  showContainer: function(containerElem) {
    imgSrc = $(containerElem).find('.container_toggle img').attr('src');
    $(containerElem).find('.container_toggle img').attr('src', imgSrc.replace('expand', 'collapse'));
  },
  hideContainer: function (containerElem) {
    imgSrc = $(containerElem).find('.container_toggle img').attr('src');
    $(containerElem).find('.container_toggle img').attr('src', imgSrc.replace('collapse', 'expand'));
  }
}

function setup_container_toggles(){
  // bind handlers
  $('.container_toggle').click(function(evt){
      toggle_target = $(this.parentNode.parentNode).find('.toggle_target');
      if(toggle_target.is(':visible')){
        // hide it
        imgSrc = $(this).find('img').attr('src');
        $(this).find('img').attr('src', imgSrc.replace('collapse', 'expand'));
        $.cookie(todoItems.buildCookieName(this.parentNode.parentNode), true);
      } else {
        // show it
        imgSrc = $(this).find('img').attr('src');
        $(this).find('img').attr('src', imgSrc.replace('expand', 'collapse'));
        $.cookie(todoItems.buildCookieName(this.parentNode.parentNode), null);
      }
      toggle_target.toggle('blind');
      });
  // set to cookied state
  $('.container.context').each(function(){
      if($.cookie(todoItems.buildCookieName(this))){
        imgSrc = $(this).find('.container_toggle img').attr('src');
        $(this).find('.container_toggle img').attr('src', imgSrc.replace('collapse', 'expand'));
        $(this).find('.toggle_target').hide();
      }
  });
}

function askIfNewContextProvided() {
  var givenContextName = $('#todo_context_name').val();
  if (givenContextName.length == 0) return true; // do nothing and depend on rails validation error
  for (var i = 0; i < contextNames.length; ++i) {
    if (contextNames[i] == givenContextName) return true;
  }
  return confirm('New context "' + givenContextName + '" will be also created. Are you sure?');
}

function update_order(event, ui){
  container = $(ui.item).parent();
  row = $(ui.item).children('.sortable_row');

  url = '';
  if(row.hasClass('context'))
    url = relative_to_root('contexts/order');
  else if(row.hasClass('project'))
    url = relative_to_root('projects/order');
  else {
    console.log("Bad sortable list");
    return;
  }
  $.post(url,
      container.sortable("serialize"),
      function(){row.effect('highlight', {}, 1000)},
      'script');
}

/* Unobtrusive jQuery behavior */

function project_defaults(){
  if(defaultContexts[$(this).val()] !== undefined) {
    context_name = $(this).parents('form').find('input[name=context_name]');
    if(context_name.attr('edited') === undefined){
      context_name.val(defaultContexts[$(this).val()]);
    }
  }
  if(defaultTags[$(this).val()] !== undefined) {
    tag_list = $(this).parents('form').find('input[name=tag_list]');
    if(tag_list.attr('edited') === undefined){
      tag_list.val(defaultTags[$(this).val()]);
    }
  }
}

function enable_rich_interaction(){
  $('input.Date').datepicker({'dateFormat': dateFormat, 'firstDay': weekStart});
  /* Autocomplete */
  $('input[name=context_name]').autocomplete(contextNames, {matchContains: true});
  $('input[name=project[default_context_name]]').autocomplete(contextNames, {matchContains: true});
  $('input[name=project_name]').autocomplete(projectNames, {matchContains: true});
  $('input[name=tag_list]:not(.ac_input)').autocomplete(tagNames, {multiple: true,multipleSeparator:',',matchContains:true});
  $('input[name=predecessor_list]:not(.ac_input)').autocomplete('/todos/auto_complete_for_predecessor',
      {multiple: true,multipleSeparator:','});

  /* have to bind on keypress because of limitataions of live() */
  $('input[name=project_name]').live('keypress', function(){
      $(this).bind('blur', project_defaults);
  });

  $('input[name=context_name]').live('keypress', function(){
      $(this).attr('edited', 'true');
  });
  $('input[name=tag_list]').live('keypress', function(){
      $(this).attr('edited', 'true');
  });

  /* Drag & Drop for successor/predecessor */
  function drop_todo(evt, ui) {
    dragged_todo = ui.draggable[0].id.split('_')[2];
    dropped_todo = $(this).parents('.item-show').get(0).id.split('_')[2];
    ui.draggable.hide();
    $(this).block({message: null});
    $.post(relative_to_root('todos/add_predecessor'),
        {successor: dragged_todo, predecessor: dropped_todo},
        null, 'script');
  }

  $('.item-show').draggable({handle: '.grip',
      revert: 'invalid',
      start: function() {$('.successor_target').show();},
      stop: function() {$('.successor_target').hide();}});

  $('.successor_target').droppable({drop: drop_todo,
      tolerance: 'pointer',
      hoverClass: 'hover'});

  /* Reset auto updater */
  field_touched = false;
}

/* Auto-refresh */

function setup_auto_refresh(interval){
  field_touched = false;
  function refresh_page() {
    if(!field_touched){
      window.location.reload();
    }
  }
  setTimeout(refresh_page, interval);
  $(function(){
      $("input").live('keydown', function(){
        field_touched = true;
        });
      });
}

$(document).ready(function() {
  $('#search-form #search').focus();

  /* Nifty corners */
  Nifty("div#recurring_new_container","normal");
  Nifty("div#context_new_container","normal");
  Nifty("div#feedlegend","normal");
  Nifty("div#feedicons-project","normal");
  Nifty("div#feedicons-context","normal");
  Nifty("div#todo_new_action_container","normal");

  /* Moved from standard.html.erb layout */
  $('ul.sf-menu').superfish({
    delay: 250,
    animation:   {opacity:'show',height:'show'},
    autoArrows: false,
    dropShadows: false,
    speed: 'fast'
  });

  $('ul.sf-item-menu').superfish({ /* context menu */
    delay: 100,
    animation:   {opacity:'show',height:'show'},
    autoArrows: false,
    dropShadows: false,
    speed: 'fast',
    onBeforeShow: function() { /* highlight todo */
      $(this.parent().parent().parent()).addClass("sf-item-selected");
    },
    onHide: function() { /* remove hightlight from todo */
      $(this.parent().parent().parent()).removeClass("sf-item-selected");
    }
  });

  /* for toggle notes link in mininav */
  $("#toggle-notes-nav").click(function () { $(".todo_notes").toggle(); });
  
  /* show the notes of a todo */
  $(".show_notes").live('click', function () {
    $(this).next().toggle("fast"); return false;
  });

  $(".show_successors").live('click', function () {
    $(this).next().toggle("fast"); return false;
  });

  /* fade flashes and alerts in automatically */
  $(".alert").fadeOut(8000);

  /* set behavior for star icon */
  $(".item-container a.star_item").live('click', function (ev){
    $.post(this.href, {_method: 'put'}, null, 'script');
    return false;
  });

  /* set behavior for toggle checkboxes */
  $(".item-container input.item-checkbox").live('click', function(ev){
    params = {_method: 'put'};
    if(typeof(TAG_NAME) !== 'undefined')
      params._tag_name = TAG_NAME;
    $.post(this.value, params, null, 'script');
  });

  /* set behavior for edit icon */
  $(".item-container a.edit_item").live('click', function (ev){
    itemContainer = $(this).parents(".item-container");
    $.ajax({
            url: this.href,
            beforeSend: function() { itemContainer.block({message: null});},
            complete: function() { itemContainer.unblock();},
            dataType: 'script'});
    return false;
  });

  setup_container_toggles();

  $('#toggle_action_new').click(function(){
    TracksForm.toggle('toggle_action_new', 'todo_new_action', 'todo-form-new-action',
      '« Hide form', 'Hide next action form',
      'Add a next action »', 'Add a next action');
    });

  $('.edit-form a.negative').live('click', function(){
      $(this).parents('.container').find('.item-show').show();
      $(this).parents('.container').find('.project').show();
      $(this).parents('.edit-form').hide();
      });
  
  /* add behavior to clear the date both buttons for show_from and due */
  $(".date_clear").live('click', function() {
      $(this).prev().val('');
    });

  /* recurring todo behavior */

  /* behavior for delete icon */
  $('.item-container a.delete_icon').live('click', function(evt){
      evt.preventDefault();
      params = {};
      if(typeof(TAG_NAME) !== 'undefined'){
        params._tag_name = TAG_NAME;
      }
      if(confirm("Are you sure that you want to "+this.title+"?")){
        itemContainer = $(this).parents(".item-container");
        itemContainer.block({message: null});
        params._method = 'delete';
        $.post(this.href, params, function(){
          itemContainer.unblock();
          }, 'script');
      }
    });

  /* behavior for edit icon */
  $('.item-container a.edit_icon').live('click', function(evt){
      evt.preventDefault();
      params = {};
      if(typeof(TAG_NAME) !== 'undefined'){
        params._tag_name = TAG_NAME;
      }
      itemContainer = $(this).parents(".item-container");
      $(this).effect('pulsate', {times: 1}, 800);
      $.get(this.href, params, function(){
        }, 'script');
    });

  $("#recurring_todo_new_action_cancel").click(function(){
      $('#recurring-todo-form-new-action input:text:first').focus();
      TracksForm.hide_all_recurring();
      $('#recurring_daily').show();
      TracksForm.toggle_overlay();
  });

  $("#recurring_todo_edit_action_cancel").live('click', function(){
      $('#recurring-todo-form-edit-action input:text:first').focus();
      TracksForm.hide_all_recurring();
      $('#recurring_daily').show();
      TracksForm.toggle_overlay();
  });
  $("#recurring_edit_period input").live('click', function(){
      $.each(['daily', 'weekly', 'monthly', 'yearly'], function(){
        $('#recurring_edit_'+this).hide();
        });
      $('#recurring_edit_'+this.id.split('_')[5]).show();
    });

  $("#recurring_period input").live('click', function(){
      $.each(['daily', 'weekly', 'monthly', 'yearly', 'target'], function(){
        $('#recurring_'+this).hide();
        });
      $('#recurring_'+this.id.split('_')[4]).show();
    });

  $('div.context span#context_name').editable(function(value, settings){
      context_id = $(this).parents('.container.context').get(0).id.split('c')[1];
      highlight = function(){
        $('div.context span#context_name').effect('highlight', {}, 500);
      };
      $.post(relative_to_root('contexts/update/'+context_id), {'context[name]': value}, highlight);
      return(value);
      }, {style: 'padding:0px', submit: "OK", cancel: "CANCEL"});

  /* Projects behavior */

  save_project_name = function(value, settings){
      project_id = $(this).parents('.container').children('div').get(0).id.split('_')[2];
      highlight = function(){
        $('h2#project_name').effect('highlight', {}, 500);
      };
      $.post(relative_to_root('projects/update/'+project_id), {'project[name]': value, 'update_project_name': 'true'}, highlight, 'script');
      return(value);
  };

  $('h2#project_name').editable(save_project_name, {style: 'padding:0px', submit: "OK"});

  $('.alphabetize_link').click(function(evt){
      evt.preventDefault();
      if(confirm('Are you sure that you want to sort these projects alphabetically? This will replace the existing sort order.')){
        alphaSort = $(this).parents('.alpha_sort');
        alphaSort.block({message:null});
        $.post(this.href, {}, function(){alphaSort.unblock()}, 'script');
      }
    });

  $('.actionize_link').click(function(evt){
      evt.preventDefault();
      if(confirm('Are you sure that you want to sort these projects by the number of tasks? This will replace the existing sort order.')){
        taskSort = $(this).parents('.tasks_sort');
        taskSort.block({message:null});
        $.post(this.href, {}, function(){taskSort.unblock()}, 'script');
      }
    });

  $('a.delete_project_button').live('click', function(evt){
      evt.preventDefault();
      if(confirm("Are you sure that you want to "+this.title+"?")){
        $(this).parents('.project').block({message: null});
        params = {_method: 'delete'};
        $.post(this.href, params, null, 'script');
      }
  });

  $('#toggle_project_new').click(function(evt){
      TracksForm.toggle('toggle_project_new', 'project_new', 'project-form',
        '« Hide form', 'Hide new project form',
        'Create a new project »', 'Add a project');
      });

  $(".project-list .edit-form a.negative").live('click', function(evt){
      evt.preventDefault();
      $(this).parents('.list').find('.project').show();
      $(this).parents('.edit-form').hide();
      $(this).parents('.edit-form').find('form').clearForm();
  });

  $(".add_note_link a").live('click', function(){
      $('#new-note').show();
      $('#new-note form').clearForm();
      $('#new-note form input:text:first').focus();
    });

  $("#list-active-projects").sortable({handle: '.handle', update: update_order});
  $("#list-hidden-projects").sortable({handle: '.handle', update: update_order});
  $("#list-completed-projects").sortable({handle: '.handle', update: update_order});

  /* Contexts behavior */
  $('#toggle_context_new').click(function(evt){
      TracksForm.toggle('toggle_context_new', 'context_new', 'context-form',
        '« Hide form', 'Hide new context form',
        'Create a new context »', 'Add a context');
  });

  $("#list-contexts-active").sortable({handle: '.handle', update: update_order});
  $("#list-contexts-hidden").sortable({handle: '.handle', update: update_order});
  
  /* Feeds page */
  $("#feed-contexts").change(function(){
      $("#feeds-for-context").load('/feedlist/get_feeds_for_context?context_id='+this.value);
  });
  $("#feed-projects").change(function(){
      $("#feeds-for-project").load('/feedlist/get_feeds_for_project?project_id='+this.value);
  });

  /* Gets called from some AJAX callbacks, too */
  enable_rich_interaction();
});
