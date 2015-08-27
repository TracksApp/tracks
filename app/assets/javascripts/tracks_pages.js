var TracksPages = {
  show_errors: function (html) {
    $('div#error_status').html(html);
    $('div#error_status').show();
  },
  show_edit_errors: function(html) {
    $('div#edit_error_status').html(html);
    $('div#edit_error_status').show();
  },
  show_errors_for_multi_add: function(html) {
    $('div#multiple_error_status').html(html);
    $('div#multiple_error_status').show();
  },
  hide_errors: function() {
    $('div#error_status').hide();
    $('div#edit_error_status').hide();
    $('div#multiple_error_status').hide();
  },
  update_sidebar: function(html) {
    $('#sidebar').html(html);
  },
  slide_up_and_remove: function(selector) {
    $(selector).slideUp(1000, function() {
      $(selector).remove();
    });
  },
  page_notify: function(type, message, fade_duration_in_sec) {
    var flash = $('div#message_holder');
    flash.html("<h4 id=\'flash\' class=\'alert "+type+"\'>"+message+"</h4>");
    flash = $('h4#flash');

    var fadein_duration = 1500;
    var fadeout_duration = 1500;
    var show_duration = fade_duration_in_sec*1000 - fadein_duration - fadeout_duration;
    if (show_duration < 0) {
      show_duration = 1000;
    }
    flash.fadeIn(fadein_duration).delay(show_duration).fadeOut(fadeout_duration);
  },
  page_error: function(message) {
    TracksPages.page_notify('error', message, 8);
  },
  page_inform: function(message) {
    TracksPages.page_notify('notice', message, 5);
  },
  set_page_badge: function(count) {
    $('#badge_count').html(count);
  },
  setup_autocomplete_for_tag_list: function(id) {
    $(id+':not(.ac_input)')
    .bind( "keydown", function( event ) { // don't navigate away from the field on tab when selecting an item
        if ( event.keyCode === $.ui.keyCode.TAB &&
            $( this ).data( "autocomplete" ).menu.active ) {
            event.preventDefault();
        }
    })
    .autocomplete({
      minLength: 2,
      autoFocus: true,
      delay: 400, /* increase a bit over the default of 300 */
      source: function( request, response ) {
        var last_term = extractLast( request.term );
        if (last_term !== "" && last_term !== " ") {
          $.ajax( {
            url: relative_to_root('tags.autocomplete'),
            dataType: 'json',
            data: {
              term: last_term
            },
            success: function(data, textStatus, jqXHR) {
              // remove spinner as removing the class is not always done by response
              $(id).removeClass('ui-autocomplete-loading');
              response(data, textStatus, jqXHR); // call jquery callback to handle data
            }
          });
        } else {
            // remove spinner as typing will always add the spinner
            $(id).removeClass('ui-autocomplete-loading');
        }
      },
      focus: function() {
        // prevent value inserted on focus
        return false;
      },
      select: function( event, ui ) {
        var terms = split( this.value );
        // remove the current input
        terms.pop();
        // add the selected item
        terms.push( ui.item.value );
        // add placeholder to get the comma-and-space at the end
        //terms.push( "" );
        this.value = terms.join( ", " );
        return false;
      }
    });
  },
  setup_all_autocompleters: function() {
    //fix for #1036 where closing a edit form before the autocomplete was filled
    //resulted in a dropdown box that could not be removed. We remove all
    //autocomplete boxes the hard way
    $('.ac_results').remove();

    // initialize autocompleters
    ProjectItems.setup_autocomplete_for_projects('input[name=project_name]');
    ContextItems.setup_autocomplete_for_contexts('input[name=context_name]');
    ContextItems.setup_autocomplete_for_contexts('input[id="project_default_context_name"]');
    TracksPages.setup_autocomplete_for_tag_list('input[name=tag_list]'); // todo edit form
    TracksPages.setup_autocomplete_for_tag_list('input[name=edit_recurring_todo_tag_list]');
    TracksPages.setup_autocomplete_for_tag_list('input[id="project_default_tags"]');
    TodoItems.setup_autocomplete_for_predecessor();
  },
  setup_datepicker: function() {
    $('input.Date').datepicker({
        'dateFormat': dateFormat,
        'firstDay': weekStart,
        'showButtonPanel': true,
        'showWeek': true,
        'changeMonth': true,
        'changeYear': true,
        'maxDate': '+5y',
        'minDate': '-1y',
        'showAnim': '' /* leave empty, see #1117 */
    });
  },
  setup_behavior: function () {
    /* context menu */
    $('ul.sf-item-menu').superfish({
        delay: 100,
        animation:   {
            opacity:'show',
            height:'show'
        },
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
    $("#toggle-notes-nav").click(function () {
        $(".todo_notes").toggle();
    });

   /* Poor man's perspectives, allows to hide any context that is collapsed */
    $("#toggle-contexts-nav").click(function () {
        /* Need to keep a single toggle across all contexts */
        $(this).toggleClass("context_visibility");
        if ($(this).hasClass("context_visibility")) {
            $(".context_collapsed").hide(); /* Hide all collapsed contexts together*/
        }
        else {
            $(".context_collapsed").show();
        }
    });

    $("a#group_view_by_link").click(function () {
        var state = $(this).attr("x_current_group_by");
        if(state === 'context'){
            state='project';
        } else {
            state='context';
        }
        $.cookie('group_view_by', state);
        refresh_page();
    });

    /* fade flashes and alerts in automatically */
    $(".alert").fadeOut(8000);
  }, sort_container: function(container) {
    function comparator(a, b) {
        var contentA = $(a).attr('data-sort') || '';
        var contentB = $(b).attr('data-sort') || '';
        if (contentA > contentB) {
            return 1;
        }
        if (contentB > contentA) {
            return -1;
        }
        return 0;
    }

    var unsortedActions = container.children();
    var sortedChildren = unsortedActions.sort(comparator);
    container.append(sortedChildren);
  }
};
