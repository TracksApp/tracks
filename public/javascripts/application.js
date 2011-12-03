var TracksForm = {
    toggle: function(toggleLinkId, formContainerId, formId, hideLinkText,
        hideLinkTitle, showLinkText, showLinkTitle) {
        var form=$('#'+formContainerId)
        form.toggle();
        var toggleLink = $('#'+toggleLinkId);
        if (!form.is(':visible')) {
            toggleLink.text(showLinkText).attr('title', showLinkTitle);
        }
        else {
            toggleLink.text(hideLinkText).attr('title', hideLinkTitle);
            $('#'+formId+' input:text:first').focus();
        }
        toggleLink.parent().toggleClass('hide_form');
    },
    set_project_name: function (name) {
        $('input#todo_project_name').val(name);
    },
    set_project_name_for_multi_add: function (name) {
        $('#multi_todo_project_name').val(name);
    },
    set_context_name: function (name) {
        $('input#todo_context_name').val(name);
    },
    set_context_name_for_multi_add: function (name) {
        $('#multi_todo_context_name').val(name);
    },
    set_context_name_and_default_context_name: function (name) {
        TracksForm.set_context_name(name);
        $('input[name=default_context_name]').val(name);
    },
    set_project_name_and_default_project_name: function (name) {
        TracksForm.set_project_name('');
        $('#default_project_name_id').val(name);
        $('#project_name').html(name);
    },
    set_tag_list: function (name) {
        $('input#todo_tag_list').val(name);
    },
    set_tag_list_for_multi_add: function (name) {
        $('#multi_tag_list').val(name);
    },
    setup_behavior: function() {
        /* toggle new todo form for single todo */
        $('#toggle_action_new').click(function(){
            if ($("#todo_multi_add").is(':visible')) { /* hide multi next action form first */
                $('#todo_new_action').show();
                $('#todo_multi_add').hide();
                $('a#toggle_multi').text(i18n['shared.toggle_multi']);
            }

            TracksForm.toggle('toggle_action_new', 'todo_new_action', 'todo-form-new-action',
                i18n['shared.hide_form'], i18n['shared.hide_action_form_title'],
                i18n['shared.toggle_single'], i18n['shared.toggle_single_title']);
        });

        /* toggle new todo form for multi edit */
        $('#toggle_multi').click(function(){
            if ($("#todo_multi_add").is(':visible')) {
                $('#todo_new_action').show();
                $('#todo_multi_add').hide();
                $('a#toggle_multi').text(i18n['shared.toggle_multi']);
            }
            else {
                $('#todo_new_action').hide();
                $('#todo_multi_add').show();
                $('a#toggle_multi').text(i18n['shared.toggle_single']);
                $('a#toggle_action_new').text(i18n['shared.hide_form']);
            }
        });

        /* add behavior to clear the date both buttons for show_from and due */
        $(".date_clear").live('click', function() {
            $(this).prev().val('');
        });

        $("#new_todo_starred_link").click(function() {
          $("#new_todo_starred").val($(this).children(".todo_star").toggleClass("starred").hasClass("starred"));
        });

        /* submit todo form after entering new todo */
        $("button#todo_new_action_submit").live('click', function (ev) {
            if ($('input#predecessor_input').val() != "")
              if (!confirm(i18n['todos.unresolved_dependency']))
                return false;
            if (TodoItems.askIfNewContextProvided('', this))
                submit_with_ajax_and_block_element('form#todo-form-new-action', $(this));
            return false;
        });

        /* submit multi-todo form after entering multiple new todos */
        $("button#todo_multi_new_action_submit").live('click', function (ev) {
            if (TodoItems.askIfNewContextProvided('multi_', this))
                submit_with_ajax_and_block_element('form#todo-form-multi-new-action', $(this));
            return false;
        });
    },
    enable_dependency_delete: function() {
        $('a[class=icon_delete_dep]').live('click', function() {
            var form = $(this).parents('form').get(0);
            var predecessor_list = $(form).find('input[name=predecessor_list]');
            var id_list = split( predecessor_list.val() );

            // remove from ul
            $(form).find("li#pred_"+this.id).slideUp(500).remove();

            // remove from array
            var new_list = new Array();
            while (id_list.length > 0) {
                var elem = id_list.pop();
                if (elem != this.id && elem != '' && elem != ' ') {
                    new_list.push ( elem );
                }
            }

            // update id list
            predecessor_list.val( new_list.join(", ") );

            if (new_list.length == 0) {
                $(form).find("label#label_for_predecessor_input").hide();
                $(form).find("ul#predecessor_ul").hide();
            }

            return false; // prevent submit/follow link
        })
    },
    generate_dependency_list: function(todo_id) {
        if (spec_of_todo.length > 0) {
            // find edit form
            var form_selector = "#form_todo_"+todo_id;
            var form = $(form_selector);

            var predecessor_list = form.find('input[name=predecessor_list]');
            var id_list = split( predecessor_list.val() );

            var label = form.find("label#label_for_predecessor_input").first();
            label.show();

            while (id_list.length > 0) {
                var elem = id_list.pop();
                var new_li = TodoItems.generate_predecessor(elem, spec_of_todo[elem]);
                var ul = form.find('ul#predecessor_ul');
                ul.html(ul.html() + new_li);
                form.find('li#pred_'+elem).show();
            }
        }
    }
}

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
    setup_nifty_corners: function() {
        Nifty("div#recurring_new_container","normal");
        Nifty("div#context_new_container","normal");
        Nifty("div#feedlegend","normal");
        Nifty("div#feedicons-project","normal");
        Nifty("div#feedicons-context","normal");
        Nifty("div#todo_new_action_container","normal");
        Nifty("div#project_new_project_container","normal");
    },
    page_notify: function(type, message, fade_duration_in_sec) {
        var flash = $('div#message_holder');
        flash.html("<h4 id=\'flash\' class=\'alert "+type+"\'>"+message+"</h4>");
        flash = $('h4#flash');

        fadein_duration = 1500;
        fadeout_duration = 1500;
        show_duration = fade_duration_in_sec*1000 - fadein_duration - fadeout_duration
        if (show_duration < 0)
          show_duration = 1000;
        flash.fadeIn(fadein_duration).delay(show_duration).fadeOut(fadeout_duration);
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
            delay: 400, /* increase a bit over dthe default of 300 */
            source: function( request, response ) {
                var last_term = extractLast( request.term );
                if (last_term != "" && last_term != " ")
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
                    })
                else {
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
        TracksPages.setup_autocomplete_for_tag_list('input[name=todo_tag_list]'); // new todo form
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
        /* main menu */
        $('ul.sf-menu').superfish({
            delay: 250,
            animation:   {
                opacity:'show',
                height:'show'
            },
            autoArrows: false,
            dropShadows: false,
            speed: 'fast'
        });

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

        /* fade flashes and alerts in automatically */
        $(".alert").fadeOut(8000);
    }
}

var TodoItemsContainer = {
    // public
    ensureVisibleWithEffectAppear: function(elemId){
        $('#'+elemId).fadeIn(500);
    },
    expandNextActionListing: function(itemsElem, skipAnimation) {
        itemsElem = $(itemsElem);
        if(skipAnimation == true) {
            itemsElem.show();
        }
        else {
            itemsElem.show('blind', 400);
        }
        TodoItems.showContainer(itemsElem.parentNode);
    },
    collapseNextActionListing: function(itemsElem, skipAnimation) {
        itemsElem = $(itemsElem);
        if(skipAnimation == true) {
            itemsElem.hide();
        }
        else {
            itemsElem.hide('blind', 400);
        }
        TodoItems.hideContainer(itemsElem.parentNode);
    },
    ensureContainerHeight: function(itemsElem) {
        $(itemsElem).css({
            height: '',
            overflow: ''
        });
    },
    expandNextActionListingByContext: function(itemsElemId, skipAnimation){
        TodoItems.expandNextActionListing($('#'+itemsElemId).get(), skipAnimation);
    },
    setup_container_toggles: function(){
        // bind handlers
        $('.container_toggle').click(function(evt){
            var toggle_target = $(this.parentNode.parentNode).find('.toggle_target');
            if(toggle_target.is(':visible')){
                // hide it
                var imgSrc = $(this).find('img').attr('src');
                $(this).find('img').attr('src', imgSrc.replace('collapse', 'expand'));
                $.cookie(TodoItemsContainer.buildCookieName(this.parentNode.parentNode), true);
                toggle_target.slideUp(500);
                // set parent class to 'context_collapsed' so we can hide/unhide all collapsed contexts
                toggle_target.parent().addClass("context_collapsed");
            } else {
                // show it
                imgSrc = $(this).find('img').attr('src');
                $(this).find('img').attr('src', imgSrc.replace('expand', 'collapse'));
                $.cookie(TodoItemsContainer.buildCookieName(this.parentNode.parentNode), null);
                toggle_target.slideDown(500);
                // remove class 'context_collapsed' from parent class
                toggle_target.parent().removeClass("context_collapsed");
            }
            return false;
        });
        // set to cookied state
        $('.container.context').each(function(){
            if($.cookie(TodoItemsContainer.buildCookieName(this))=="true"){
                var imgSrc = $(this).find('.container_toggle img').attr('src');
                if (imgSrc) {
                    $(this).find('.container_toggle img').attr('src', imgSrc.replace('collapse', 'expand'));
                    $(this).find('.toggle_target').hide();
                    $(this).find('.toggle_target').parent().addClass("context_collapsed");
                }
            }
        });
    },

    // private
    buildCookieName: function(containerElem) {
        var tracks_login = $.cookie('tracks_login');
        return 'tracks_'+tracks_login+'_context_' + containerElem.id + '_collapsed';
    },
    showContainer: function(containerElem) {
        var imgSrc = $(containerElem).find('.container_toggle img').attr('src');
        $(containerElem).find('.container_toggle img').attr('src', imgSrc.replace('expand', 'collapse'));
    },
    hideContainer: function (containerElem) {
        var imgSrc = $(containerElem).find('.container_toggle img').attr('src');
        $(containerElem).find('.container_toggle img').attr('src', imgSrc.replace('collapse', 'expand'));
    }
}

var TodoItems = {
    getContextsForAutocomplete: function (term, element_to_block) {
        var allContexts = null;
        var params = default_ajax_options_for_scripts('GET', relative_to_root('contexts.autocomplete'), element_to_block);
        params.data += "&term="+term;
        params.dataType = "json";
        params.async = false;
        params.success = function(result){
            allContexts = result;
        }
        $.ajax(params);
        return allContexts;
    },
    askIfNewContextProvided: function(source, element_to_block) {
        var givenContextName = $('#'+source+'todo_context_name').val();
        if (givenContextName.length == 0) return true; // do nothing and depend on rails validation error

        var contexts = TodoItems.getContextsForAutocomplete(givenContextName, element_to_block);

        if (contexts) {
            for (var i=0; i<contexts.length; i++)
                if (contexts[i].value == givenContextName) return true;
        }
        return confirm(i18n['contexts.new_context_pre'] + givenContextName + i18n['contexts.new_context_post']);
    },
    generate_predecessor: function(todo_id, todo_spec) {
        var img = "<img id=\"delete_dep_"+todo_id+"\" class=\"icon_delete_dep\" src=\""+ relative_to_root('images/blank.png') + "\">";
        var anchor = "<a class=\"icon_delete_dep\" id=\""+todo_id+"\" href=\"#\">" + img + "</a>";
        var li = "<li style=\"display:none\" id=\"pred_"+todo_id+"\">"+ anchor +" "+ todo_spec + "</li>";
        return li;
    },
    highlight_todo: function(id) {
        $(id).effect('highlight', {}, 2000, function(){ });
    },
    setup_autocomplete_for_predecessor: function() {
        $('input[name=predecessor_input]:not(.ac_input)')
        .bind( "keydown", function( event ) { // don't navigate away from the field on tab when selecting an item
            if ( event.keyCode === $.ui.keyCode.TAB &&
                $( this ).data( "autocomplete" ).menu.active ) {
                event.preventDefault();
            }
        })
        .autocomplete({
            minLength: 2,
            autoFocus: true,
            delay: 400, /* delay a bit more than the default of 300 */
            source: function( request, response ) {
                var term = request.term;
                if (term != "" && term != " ")
                    $.getJSON( relative_to_root('auto_complete_for_predecessor'), {
                        term: term
                    }, response );
            },
            focus: function() {
                // prevent value inserted on focus
                return false;
            },
            select: function( event, ui ) {
                // retrieve values from input fields
                var todo_spec = ui.item.label
                var todo_id = ui.item.value
                var form = $(this).parents('form').get(0);
                var predecessor_list = $(form).find('input[name=predecessor_list]')
                var id_list = split( predecessor_list.val() );

                // add the dependency to id list
                id_list.push( todo_id );
                predecessor_list.val( id_list.join( ", " ) );

                // show the html for the list of deps
                $(form).find('ul#predecessor_ul').show();
                $(form).find("label#label_for_predecessor_input").show();
                if (todo_spec.length > 35 && form.id == "todo-form-new-action") {
                    // cut off string only in new-todo-form
                    todo_spec = todo_spec.substring(0,40)+"...";
                }
                // show the new dep in list
                var html = $(form).find('ul#predecessor_ul').html();
                var new_li = TodoItems.generate_predecessor(todo_id, todo_spec);
                $(form).find('ul#predecessor_ul').html(html + new_li);
                $(form).find('li#pred_'+todo_id).slideDown(500);

                $(form).find('input[name=predecessor_input]').val('');
                $(form).find('input[name=predecessor_input]').focus();
                return false;
            }
        });
    },
    drag_todo: function() {
        $('.drop_target').show();
        $(this).parents(".container").find(".context_target").hide();
    },
    drop_todo: function(evt, ui) {
        /* Drag & Drop for successor/predecessor */
        var dragged_todo = ui.draggable[0].id.split('_')[2];
        var dropped_todo = this.id.split('_')[2];
        ui.draggable.remove();
        $('.drop_target').hide(); // IE8 doesn't call stop() in this situation

        ajax_options = default_ajax_options_for_scripts('POST', relative_to_root('todos/add_predecessor'), $(this));
        ajax_options.data += "&predecessor="+dropped_todo + "&successor="+dragged_todo
        $.ajax(ajax_options);
    },
    drop_todo_on_context: function(evt, ui) {
        /* Drag & drop for changing contexts */
        var target = $(this).parent().get();
        var dragged_todo = ui.draggable[0].id.split('_')[2];
        var context_id = this.id.split('_')[1];
        ui.draggable.remove();
        $('.drop_target').hide();

        ajax_options = default_ajax_options_for_scripts('POST', relative_to_root('todos/change_context'), target);
        ajax_options.data += "&todo[id]="+dragged_todo + "&todo[context_id]="+context_id
        $.ajax(ajax_options);
    },
    setup_drag_and_drop: function() {
        $('.item-show').draggable({
            handle: '.grip',
            revert: 'invalid',
            start: TodoItems.drag_todo,
            stop: function() {
                $('.drop_target').hide();
            }
        });
        $('.item-show').droppable({
            drop: TodoItems.drop_todo,
            tolerance: 'pointer',
            hoverClass: 'hover'
        });
        $('.context_target').droppable({
            drop: TodoItems.drop_todo_on_context,
            tolerance: 'pointer',
            hoverClass: 'hover'
        });
    },
    setup_behavior: function() {
        /* show the notes of a todo */
        $(".show_notes").live('click', function () {
            $(this).next().toggle("fast");
            return false;
        });

        $(".show_successors").live('click', function () {
            $(this).next().toggle("fast");
            return false;
        });

        /* set behavior for star icon */
        $(".item-container a.star_item").live('click', function (ev){
            put_with_ajax_and_block_element(this.href, $(this));
            return false;
        });

        /* set behavior for toggle checkboxes for Recurring Todos */
        $(".item-container input.item-checkbox").live('click', function(ev){
            put_with_ajax_and_block_element(this.value, $(this).parents(".item-container"));
            return false;
        });

        /* set behavior for edit icon */
        $(".item-container a.edit_item").live('click', function (ev){
            var ajax_options = default_ajax_options_for_scripts('GET', this.href, $(this).parents('.item-container'));
            var id = this.id.substr(15);
            ajax_options.complete.push( function(){
                TracksForm.generate_dependency_list(id);
            });
            $.ajax(ajax_options);
            return false;
        });

        /* delete button to delete a todo from the list */
        $('.item-container a.icon_delete_item').live('click', function(evt){
            var confirm_message = $(this).attr("x_confirm_message")
            if(confirm(confirm_message)){
                delete_with_ajax_and_block_element(this.href, $(this).parents('.item-container'));
            }
            return false;
        });

        /* submit todo form after edit */
        $("form.edit_todo_form button.positive").live('click', function (ev) {
            submit_with_ajax_and_block_element('form.edit_todo_form', $(this));
            return false;
        });

        // for cancelling edit todo form
        $('form.edit_todo_form a.negative').live('click', function(){
            $(this).parents('.edit-form').fadeOut(200, function () {
                $(this).parents('.list').find('.project').fadeIn(500);
                $(this).parents('.container').find('.item-show').fadeIn(500);
            })
        });

        // defer a todo
        $(".item-container a.icon_defer_item").live('click', function(ev){
            if ($(this).attr("x_defer_alert") == "true")
                alert ($(this).attr("x_defer_date_after_due_date"));
            else
                put_with_ajax_and_block_element(this.href, $(this).parents(".item-container"));
            return false;
        });

        /* delete button to delete a project from the list */
        $('.item-container a.delete_dependency_button').live('click', function(evt){
            var predecessor_id=$(this).attr("x_predecessors_id");
            var ajax_options = default_ajax_options_for_scripts('DELETE', this.href, $(this).parents('.item-container'));
            ajax_options.data += "&predecessor="+predecessor_id
            $.ajax(ajax_options);
            return false;
        });

        TracksForm.enable_dependency_delete();
    }
}

var ContextItems = {
    setup_autocomplete_for_contexts: function(id) {
        $(id).autocomplete({
            source: relative_to_root('contexts.autocomplete'),
            autoFocus: true,
            minLength: 1,
            delay: 400 /* increase a bit. default was 300 */
        });
    }
}

var ProjectItems = {
    setup_autocomplete_for_projects: function(id) {
        $(id).autocomplete({
            source: relative_to_root('projects.autocomplete'),
            autoFocus: true,
            minLength: 1,
            delay: 400 /* increase a bit. default was 300 */
        });
    }
}

var UsersPage = {
    setup_behavior: function() {
        /* delete button to delete a user from the list */
        $('a.delete_user_button').live('click', function(evt){
            var confirm_message = $(this).attr("x_confirm_message")
            if(confirm(confirm_message)){
                delete_with_ajax_and_block_element(this.href, $(this).parents('.project'));
            }
            return false;
        });

    }
}

var PreferencesPage = {
    get_date_format: function(tag_name) {
        var value = $('input[name="prefs['+tag_name+']"]').val();
        var element = 'span[id="prefs.'+tag_name+'"]';
        var url = 'preferences/render_date_format';
        var param = "date_format="+encodeURIComponent( value );
        generic_get_script_for_list(element, url, param);
      },
    setup_getter_for_date_format: function(tag_name) {
      $('input[name="prefs['+tag_name+']"]').change(function() {
        PreferencesPage.get_date_format(tag_name);
      });
    },
    setup_behavior: function() {
      $( "#tabs" ).tabs();

      $( "button#prefs_submit" ).button();

      $('input[name="user[auth_type]"]').change(function() {
        var value = $('input[name="user[auth_type]"]:checked').val();
        $('#open_id')[0].style.display = value == 'open_id' ? 'block' : 'none'
        $('#database')[0].style.display = value == 'database' ? 'block' : 'none'
      });

      $('input[name="date_picker1"]').change(function() {
        var value = $('input[name="date_picker1"]:checked').val();
        $('input[name="prefs[date_format]"]').val(value);
        PreferencesPage.get_date_format('date_format');
      });

      $('input[name="date_picker2"]').change(function() {
        var value = $('input[name="date_picker2"]:checked').val();
        $('input[name="prefs[title_date_format]"]').val(value);
        PreferencesPage.get_date_format('title_date_format');
      });

      PreferencesPage.setup_getter_for_date_format('date_format');
      PreferencesPage.setup_getter_for_date_format('title_date_format');
    }
}

var ProjectListPage = {
    update_state_count: function(state, count) {
        $('#'+state+'-projects-count').html(count);
    },
    update_all_states_count: function (active_count, hidden_count, completed_count) {
        $(["active", "hidden", "completed"]).each(function() {
            ProjectListPage.update_state_count(this, eval(this+'_count'));
        });
    },
    show_or_hide_all_state_containers: function (show_active, show_hidden, show_completed) {
        $(["active", "hidden", "completed"]).each(function() {
            ProjectListPage.set_state_container_visibility(this, eval('show_'+this));
        });
    },
    set_state_container_visibility: function (state, set_visible) {
        if (set_visible) {
            $('#list-'+state+'-projects-container').slideDown("fast");
        } else {
            $('#list-'+state+'-projects-container').slideUp("fast");
        }
    },
    save_project_name: function(value, settings){
        var project_id = $(this).parents('.container').children('div').get(0).id.split('_')[2];
        var highlight = function(){
            $('h2#project_name').effect('highlight', {}, 500);
        };
        $.post(relative_to_root('projects/update/'+project_id), {
            'project[name]': value,
            'update_project_name': 'true'
        }, highlight, 'script');
        return(value);
    },
    setup_behavior: function() {
        /* in-place edit of project name */
        $('div#project_name').editable(ProjectListPage.save_project_name, {
            style: 'padding: 0px; width=100%;',
            submit: i18n['common.ok'],
            cancel: i18n['common.cancel'],
            onblur: 'cancel'
        });

        /* alphabetize project list */
        $('.alphabetize_link').live('click', function(evt){
            var confirm_message = $(this).attr("x_confirm_message")
            if(confirm(confirm_message)){
                post_with_ajax_and_block_element(this.href, $(this).parents('.alpha_sort'));
            }
            return false;
        });

        /* sort by number of actions */
        $('.actionize_link').click(function(evt){
            var confirm_message = $(this).attr("x_confirm_message")
            if(confirm(confirm_message)){
                post_with_ajax_and_block_element(this.href, $(this).parents('.tasks_sort'));
            }
            return false;
        });

        /* delete button to delete a project from the list */
        $('a.delete_project_button').live('click', function(evt){
            var confirm_message = $(this).attr("x_confirm_message")
            if(confirm(confirm_message)){
                delete_with_ajax_and_block_element(this.href, $(this).parents('.project'));
            }
            return false;
        });

        /* set behavior for edit project settings link in both projects list page and project page */
        $("a.project_edit_settings").live('click', function (evt) {
            get_with_ajax_and_block_element(this.href, $(this).parent().parent());
            return false;
        });

        /* submit project form after edit */
        $("form.edit-project-form button.positive").live('click', function (ev) {
            $('div#project_name').editable('enable');
            submit_with_ajax_and_block_element('form.edit-project-form', $(this));
            return false;
        });

        /* cancel edit project form */
        $('form.edit-project-form a.negative').live('click', function(){
            $('div#project_name').editable('enable');
            $(this).parents('.edit-form').fadeOut(200, function () {
                $(this).parents('.list').find('.project').fadeIn(500);
                $(this).parents('.container').find('.item-show').fadeIn(500);
            })
        });

        /* submit project form after entering new project */
        $("form#project_form button.positive").live('click', function (ev) {
            submit_with_ajax_and_block_element('form.#project_form', $(this));
            return false;
        });

        /* toggle new project form */
        $('#toggle_project_new').click(function(evt){
            TracksForm.toggle('toggle_project_new', 'project_new', 'project-form',
                i18n['projects.hide_form'], i18n['projects.hide_form_title'],
                i18n['projects.show_form'], i18n['projects.show_form_title']);
        });

        /* make the three lists of project sortable */
        $(['active', 'hidden', 'completed']).each(function() {
            $("#list-"+this+"-projects").sortable({
                handle: '.handle',
                update: update_order
            });
        });

        $('#project_new #project_name').focus();
    }
}

var ContextListPage = {
    update_state_count: function(state, count) {
        $('#'+state+'-contexts-count').html(count);
    },
    update_all_states_count: function (active_count, hidden_count, completed_count) {
        $(["active", "hidden"]).each(function() {
            ContextListPage.update_state_count(this, eval(this+'_count'));
        });
    },
    show_or_hide_all_state_containers: function (show_active, show_hidden, show_completed) {
        $(["active", "hidden"]).each(function() {
            ContextListPage.set_state_container_visibility(this, eval('show_'+this));
        });
    },
    set_state_container_visibility: function (state, set_visible) {
        if (set_visible) {
            $('#list-'+state+'-contexts-container').slideDown("fast");
        } else {
            $('#list-'+state+'-contexts-container').slideUp("fast");
        }
    },
    save_context_name: function(value, settings) {
        var context_id = $(this).parents('.container.context').get(0).id.split('c')[1];
        var highlight = function(){
            $('div.context span#context_name').effect('highlight', {}, 500);
        };
        $.post(relative_to_root('contexts/update/'+context_id), {
            'context[name]': value
        }, highlight);
        return value;
    },
    setup_behavior: function() {
        /* in place edit of context name */
        $('div.context span#context_name').editable(ContextListPage.save_context_name, {
            style: 'padding:0px',
            submit: i18n['common.ok'],
            cancel: i18n['common.cancel']
        });

        /* delete a context using the x button */
        $('a.delete_context_button').live('click', function(evt){
            var confirm_message = $(this).attr("x_confirm_message")
            if(confirm(confirm_message)){
                delete_with_ajax_and_block_element(this.href, $(this).parents('.context'));
            }
            return false;
        });

        /* set behavior for edit context settings link in projects list page and project page */
        $("a.context_edit_settings").live('click', function (ev) {
            get_with_ajax_and_block_element(this.href, $(this).parent().parent());
            return false;
        });

        /* submit form when editing a context */
        $("form.edit-context-form button.positive").live('click', function (ev) {
            submit_with_ajax_and_block_element('form.edit-context-form', $(this));
            return false;
        });

        /* submit form for new context in sidebar */
        $("form#context-form button.positive").live('click', function (ev) {
            submit_with_ajax_and_block_element('form.#context-form', $(this));
            return false;
        });

        /* Contexts behavior */
        $('#toggle_context_new').click(function(evt){
            TracksForm.toggle('toggle_context_new', 'context_new', 'context-form',
                i18n['contexts.hide_form'], i18n['contexts.hide_form_title'],
                i18n['contexts.show_form'], i18n['contexts.show_form_title']);
        });

        /* make the two state lists of context sortable */
        $(['active', 'hidden']).each(function() {
            $("#list-contexts-"+this).sortable({
                handle: '.handle',
                update: update_order
            })
        });

        $('#context-form #context_name').focus();
    }
}

var IntegrationsPage = {
    setup_behavior: function() {
        $('#applescript1-contexts').live('change', function(){
            IntegrationsPage.get_script_for_context("#applescript1", "get_applescript1", this.value);
        });
        $('#applescript2-contexts').live('change', function(){
            IntegrationsPage.get_script_for_context("#applescript2", "get_applescript2", this.value);
        });
        $('#quicksilver-contexts').live('change', function(){
            IntegrationsPage.get_script_for_context("#quicksilver", "get_quicksilver_applescript", this.value)
        });
    },
    get_script_for_context: function(element, getter, context){
        generic_get_script_for_list(element, "integrations/"+getter, "context_id="+context);
    }
}

var FeedsPage = {
    setup_behavior: function() {
        /* TODO: blocking of dropdown */
        $("#feed-contexts").change(function(){
            FeedsPage.get_script_for_context("#feeds-for-context", "get_feeds_for_context", this.value );
        });
        $("#feed-projects").change(function(){
            FeedsPage.get_script_for_project("#feeds-for-project", "get_feeds_for_project", this.value );
        });
    },
    get_script_for_context: function(element, getter, context){
        generic_get_script_for_list(element, "feedlist/"+getter, "context_id="+context);
    },
    get_script_for_project: function(element, getter, project){
        generic_get_script_for_list(element, "feedlist/"+getter, "project_id="+project);
    }
}

var NotesPage = {
    setup_behavior: function() {
        /* Add note */
        $(".add_note_link a").live('click', function(){
            $('#new-note').show();
            $('textarea#note_body').val('');
            $('textarea#note_body').focus();
        });

        /* delete button for note */
        $('a.delete_note_button').live('click', function(){
            var confirm_message = $(this).attr("x_confirm_message")
            if(confirm(confirm_message)){
                delete_with_ajax_and_block_element(this.href, $(this).parents('.project_notes'));
            }
            return false;
        });

        /* edit button for note */
        $('a.note_edit_settings').live('click', function(){
            var dom_id = this.id.substr(10);
            $('#'+dom_id).toggle();
            $('#edit_'+dom_id).show();
            $('#edit_form_'+dom_id+' textarea').focus();
            return false;
        });

        /* cancel button when editing a note */
        $('.edit-note-form a.negative').live('click', function(){
            var dom_id = this.id.substr(14);
            /* dom_id == 'note_XX' on notes page and just 'note' on project page */
            if (dom_id == 'note') {
                $('#new-note').hide();
            } else {
                $('#'+dom_id).toggle();
                $('#edit_'+dom_id).hide();
            }
            return false;
        });

        /* update button when editing a note */
        $("form.edit-note-form button.positive").live('click', function (ev) {
            submit_with_ajax_and_block_element($(this).parents('form.edit-note-form'), $(this));
            return false;
        });
    }
}

var RecurringTodosPage = {
    hide_all_recurring: function () {
        $.each(['daily', 'weekly', 'monthly', 'yearly'], function(){
            $('#recurring_'+this).hide();
        });
    },
    hide_all_edit_recurring: function () {
        $.each(['daily', 'weekly', 'monthly', 'yearly'], function(){
            $('#recurring_edit_'+this).hide();
        });
    },
    reset_radio: function () {
      $('input:radio[name="recurring_todo[recurring_period]"]')[0].checked = true;
    },
    toggle_overlay: function () {
        var overlay_element = document.getElementById("overlay");
        overlay_element.style.visibility = (overlay_element.style.visibility == "visible") ? "hidden" : "visible";
    },
    setup_behavior: function() {
      /* add new recurring todo plus-button in sidebar */
      $("#add-new-recurring-todo").live('click', function(){
        $( "#new-recurring-todo" ).dialog( "open" );
      });

      /* setup dialog for new repeating action */
      $( "#new-recurring-todo" ).dialog({
    		autoOpen: false,
        height: 690,
  			width: 750,
  			modal: true,
        buttons: {
          "Create": function() { submit_with_ajax_and_block_element('form.#recurring-todo-form-new-action', $(this).parents(".ui-dialog")); },
          Cancel: function() { $( this ).dialog( "close" ); }
        },
        show: "fade",
        hide: "fade",
        close: function() {
          $('#recurring-todo-form-new-action input:text:first').focus();
          RecurringTodosPage.hide_all_recurring();
          RecurringTodosPage.reset_radio();
          $('#recurring_daily').show();
        }
      });

      /* change recurring period radio input on new form */
      $("#recurring_period input").live('click', function(){
          RecurringTodosPage.hide_all_recurring();
          $('#recurring_'+this.id.split('_')[4]).show();
      });

      /* setup dialog for new repeating action */
      $( "#edit-recurring-todo" ).dialog({
    		autoOpen: false,
        height: 690,
  			width: 750,
  			modal: true,
        buttons: {
          "Update": {
            text: "Update",
            id: 'recurring_todo_edit_update_button',
            click: function() { submit_with_ajax_and_block_element('form#recurring-todo-form-edit-action', $(this).parents(".ui-dialog")); }
          },
          Cancel: function() { $( this ).dialog( "close" ); }
        },
        show: "fade",
        hide: "fade",
        close: function() {
          $('#recurring-todo-form-edit-action input:text:first').focus();
          RecurringTodosPage.hide_all_recurring();
          RecurringTodosPage.reset_radio();
          $('#recurring_daily').show();
        }
      });

      /* change recurring period radio input on edit form */
      $("#recurring_edit_period input").live('click', function(){
          RecurringTodosPage.hide_all_edit_recurring();
          $('#recurring_edit_'+this.id.split('_')[5]).show();
      });

      /* set behavior for edit recurring todo */
      $(".item-container a.edit_icon").live('click', function (ev){
          get_with_ajax_and_block_element(this.href, $(this).parents(".item-container"));
          return false;
      });

      /* delete button to delete a todo from the list */
      $('.item-container a.delete_icon').live('click', function(evt){
          var confirm_message = $(this).attr("x_confirm_message")
          if(confirm(confirm_message)){
              delete_with_ajax_and_block_element(this.href, $(this).parents('.project'));
            }
          return false;
      });

    }
}

var SearchPage = {
    setup_behavior: function() {
        $('#search-form #search').focus();
    }
}

/**************************************/
/* generic Tracks functions           */
/**************************************/

function redirect_to(path) {
    window.location.href = path;
}

function refresh_page() {
    location.reload(true);
}

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

function split( val ) {
    return val.split( /,\s*/ );
}
function extractLast( term ) {
    return split( term ).pop();
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

$.fn.clearDeps = function() {
    $('ul#predecessor_ul', this).hide();
    $("label#label_for_predecessor_input").hide();
    $('ul#predecessor_ul', this).html("");
    $('input[name=predecessor_list]').val("");
}

/**************************************/
/* Tracks AJAX functions              */
/**************************************/

function generic_get_script_for_list(element, getter, param){
    $(element).load(relative_to_root(getter+'?'+param));
}

function default_ajax_options_for_submit(ajax_type, element_to_block) {
    // the complete is not a function but an array so you can push other
    // functions that will be executed after the ajax call completes
    var options = {
        type: ajax_type,
        async: true,
        block_element: element_to_block,
        data: "_source_view=" + SOURCE_VIEW,
        beforeSend: function() {
            if (this.block_element) {
                $(this.block_element).block({
                    message: null
                });
            }
        },
        complete: [function() {
            if (this.block_element) {
                $(this.block_element).unblock();
            }
            // delay a bit to wait for animations to finish
            setTimeout(function(){
                enable_rich_interaction();
            }, 500);
        }],
        error: function(req, status) {
            TracksPages.page_notify('error', i18n['common.ajaxError']+': '+status, 8);
        }
    }
    if(typeof(TAG_NAME) !== 'undefined')
        options.data += "&_tag_name="+ TAG_NAME;
    return options;
}

function default_ajax_options_for_scripts(ajax_type, the_url, element_to_block) {
    var options = default_ajax_options_for_submit(ajax_type, element_to_block);
    options.url = the_url;
    options.dataType = 'script';
    return options;
}

function submit_with_ajax_and_block_element(form, element_to_block) {
    var options = default_ajax_options_for_submit('POST', element_to_block);
    options.dataType = 'script';
    $(form).ajaxSubmit(options);
}

function get_with_ajax_and_block_element(the_url, element_to_block) {
    $.ajax(default_ajax_options_for_scripts('GET', the_url, element_to_block));
}

function post_with_ajax_and_block_element(the_url, element_to_block) {
    $.ajax(default_ajax_options_for_scripts('POST', the_url, element_to_block));
}

function put_with_ajax_and_block_element(the_url, element_to_block) {
    var options = default_ajax_options_for_scripts('POST', the_url, element_to_block);
    options.data += '&_method=put';
    $.ajax(options);
}

function delete_with_ajax_and_block_element(the_url, element_to_block) {
    $.ajax(default_ajax_options_for_scripts('DELETE', the_url, element_to_block));
}

$(document).ajaxSend(function(event, request, settings) {
    /* Set up authenticity token properly */
    if ( settings.type == 'POST' || settings.type == 'post' ) {
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
    request.setRequestHeader('X-CSRF-Token', $('meta[name=csrf-token]').attr('content'));
    request.setRequestHeader("Accept", "text/javascript");
});

function setup_periodic_check(url_for_check, interval_in_sec, method) {
    setInterval(
        function(){
            var settings = default_ajax_options_for_scripts( method ? method : "GET", url_for_check, null);
            if(typeof(AUTH_TOKEN) != 'undefined'){
                settings.data += "&authenticity_token=" + encodeURIComponent( AUTH_TOKEN )
            }
            $.ajax(settings);
        },
        interval_in_sec*1000
        );
}

function update_order(event, ui){
    var container = $(ui.item).parent();
    var row = $(ui.item).children('.sortable_row');

    var url = '';
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
        function(){
            row.effect('highlight', {}, 1000)
        },
        'script');
}

function project_defaults(){
    if($('body').hasClass('contexts')){
    // don't change the context
    // see ticket #934
    } else {
        if(defaultContexts[$(this).val()] !== undefined) {
            var context_name = $(this).parents('form').find('input[name=context_name]');
            if(context_name.attr('edited') === undefined){
                context_name.val(defaultContexts[$(this).val()]);
            }
        }
    }
    if(defaultTags[$(this).val()] !== undefined) {
        var tag_list = $(this).parents('form').find('input[name=tag_list]');
        if(tag_list.attr('edited') === undefined){
            tag_list.val(defaultTags[$(this).val()]);
        }
    }
}

function enable_rich_interaction(){
    // called after completion of all AJAX calls

    TracksPages.setup_datepicker();
    TracksPages.setup_all_autocompleters();
    TodoItems.setup_drag_and_drop();

    /* have to bind on keypress because of limitations of live() */
    $('input[name=project_name]').live('keypress', function(){
        $(this).bind('blur', project_defaults);
    });
    $('input[name=context_name]').live('keypress', function(){
        $(this).attr('edited', 'true');
    });
    $('input[name=tag_list]').live('keypress', function(){
        $(this).attr('edited', 'true');
    });

    /* Reset auto updater */
    field_touched = false;

    /* shrink the notes on the project pages. This is not live(), so this needs
     * to be run after ajax adding of a new note */
    $('.note_wrapper').truncate({
        max_length: 90,
        more: '',
        less: ''
    });
}

$(document).ready(function() {

    // fix for IE8. Without this checkboxes don't work AJAXy. See #1152
    if($.browser.msie && ($.browser.version.substring(0, 2) == "8.")) {
        $('body').bind('change', function() {
            return true;
        });
    }

    TracksPages.setup_nifty_corners();

    TodoItemsContainer.setup_container_toggles();

    /* enable page specific behavior */
    $([ 'PreferencesPage', 'IntegrationsPage', 'NotesPage', 'ProjectListPage', 'ContextListPage',
        'FeedsPage', 'RecurringTodosPage', 'TodoItems', 'TracksPages',
        'TracksForm', 'SearchPage', 'UsersPage' ]).each(function() {
        eval(this+'.setup_behavior();');
    });

    /* Gets called from all AJAX callbacks, too */
    enable_rich_interaction();
});
