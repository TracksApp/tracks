var TracksForm = {
    toggle: function(toggleLinkId, formContainerId, formId, hideLinkText,
        hideLinkTitle, showLinkText, showLinkTitle) {
        form=$('#'+formContainerId)
        form.toggle();
        toggleLink = $('#'+toggleLinkId);
        if (!form.is(':visible')) {
            toggleLink.text(showLinkText).attr('title', showLinkTitle);
        }
        else {
            toggleLidefault_ajax_optionsnk.text(hideLinkText).attr('title', hideLinkTitle);
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
        $('input#tag_list').val(name);
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
                $('a#toggle_multi').text("Add multiple next actions");
            }

            TracksForm.toggle('toggle_action_new', 'todo_new_action', 'todo-form-new-action',
                '« Hide form', 'Hide next action form',
                'Add a next action »', 'Add a next action');
        });

        /* toggle new todo form for multi edit */
        $('#toggle_multi').click(function(){
            if ($("#todo_multi_add").is(':visible')) {
                $('#todo_new_action').show();
                $('#todo_multi_add').hide();
                $('a#toggle_multi').text("Add multiple next actions");
            }
            else {
                $('#todo_new_action').hide();
                $('#todo_multi_add').show();
                $('a#toggle_multi').text("Add single next action");
                $('a#toggle_action_new').text('« Hide form');
            }
        });

        /* add behavior to clear the date both buttons for show_from and due */
        $(".date_clear").live('click', function() {
            $(this).prev().val('');
        });

        /* behavior for delete icon */
        $('.item-container a.delete_icon').live('click', function(evt){
            evt.preventDefault();
            params = {};
            if(typeof(TAG_NAME) !== 'undefined'){
                params._tag_name = TAG_NAME;
            }
            if(confirm("Are you sure that you want to "+this.title+"?")){
                itemContainer = $(this).parents(".item-container");
                itemContainer.block({
                    message: null
                });
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
            $(this).effect('pulsate', {
                times: 1
            }, 800);
            $.get(this.href, params, function(){
                }, 'script');
        });

        /* submit todo form after entering new todo */
        $("button#todo_new_action_submit").live('click', function (ev) {
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
        flash = $('h4#flash');
        flash.html("<h4 id=\'flash\' class=\'alert "+type+"\'>"+message+"</h4>");
        flash = $('h4#flash');
        flash.show();
        flash.fadeOut(fade_duration_in_sec*1000);
    },
    set_page_badge: function(count) {
        $('#badge_count').html(count);
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

        /* fade flashes and alerts in automatically */
        $(".alert").fadeOut(8000);

        /* for edit project form and edit todo form
         * TODO: refactor to separate calls from project and todo */
        $('.edit-form a.negative').live('click', function(){
            $(this).parents('.edit-form').fadeOut(200, function () {
                $(this).parents('.list').find('.project').fadeIn(500);
                $(this).parents('.container').find('.item-show').fadeIn(500);
            })
        });

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
            toggle_target = $(this.parentNode.parentNode).find('.toggle_target');
            if(toggle_target.is(':visible')){
                // hide it
                imgSrc = $(this).find('img').attr('src');
                $(this).find('img').attr('src', imgSrc.replace('collapse', 'expand'));
                $.cookie(TodoItemsContainer.buildCookieName(this.parentNode.parentNode), true);
                toggle_target.slideUp(500);
            } else {
                // show it
                imgSrc = $(this).find('img').attr('src');
                $(this).find('img').attr('src', imgSrc.replace('expand', 'collapse'));
                $.cookie(TodoItemsContainer.buildCookieName(this.parentNode.parentNode), null);
                toggle_target.slideDown(500);
            }
            return false;
        });
        // set to cookied state
        $('.container.context').each(function(){
            if($.cookie(TodoItemsContainer.buildCookieName(this))=="true"){
                imgSrc = $(this).find('.container_toggle img').attr('src');
                if (imgSrc) {
                    $(this).find('.container_toggle img').attr('src', imgSrc.replace('collapse', 'expand'));
                    $(this).find('.toggle_target').hide();
                }
            }
        });
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

var TodoItems = {
    getContextsForAutocomplete: function (term, element_to_block) {
        var allContexts = null;
        params = default_ajax_options_for_scripts('GET', relative_to_root('contexts.autocomplete'), element_to_block);
        params.data = "term="+term;
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

        contexts = TodoItems.getContextsForAutocomplete(givenContextName, element_to_block);

        if (contexts) {
            for (i=0; i<contexts.length; i++)
                if (contexts[i].value == givenContextName) return true;
        }
        return confirm('New context "' + givenContextName + '" will be also created. Are you sure?');
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
            get_with_ajax_and_block_element(this.href, $(this).parents(".item-container"));
            return false;
        });

        /* delete button to delete a project from the list */
        $('.item-container a.icon_delete_item').live('click', function(evt){
            if(confirm(this.title)){
                delete_with_ajax_and_block_element(this.href, $(this).parents('.project'));
            }
            return false;
        });

        /* submit todo form after edit */
        $("form.edit_todo_form button.positive").live('click', function (ev) {
            submit_with_ajax_and_block_element('form.edit_todo_form', $(this));
            return false;
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
            predecessor_id=$(this).attr("x_predecessors_id");
            ajax_options = default_ajax_options_for_scripts('DELETE', this.href, $(this).parents('.item-container'));
            ajax_options.data += "&predecessor="+predecessor_id
            $.ajax(ajax_options);
            return false;
        });
    }
}

var UsersPage = {
    setup_behavior: function() {
        /* delete button to delete a usedr from the list */
        $('a.delete_user_button').live('click', function(evt){
            confirm_message = $(this).attr("x_confirm_message")
            if(confirm(confirm_message)){
                delete_with_ajax_and_block_element(this.href, $(this).parents('.project'));
            }
            return false;
        });

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
        project_id = $(this).parents('.container').children('div').get(0).id.split('_')[2];
        highlight = function(){
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
        $('h2#project_name').editable(ProjectListPage.save_project_name, {
            style: 'padding:0px',
            submit: "OK",
            cancel: "CANCEL"
        });

        /* alphabetize project list */
        $('.alphabetize_link').live('click', function(evt){
            if(confirm('Are you sure that you want to sort these projects alphabetically? This will replace the existing sort order.')){
                post_with_ajax_and_block_element(this.href, $(this).parents('.alpha_sort'));
            }
            return false;
        });

        /* sort by number of actions */
        $('.actionize_link').click(function(evt){
            if(confirm('Are you sure that you want to sort these projects by the number of tasks? This will replace the existing sort order.')){
                post_with_ajax_and_block_element(this.href, $(this).parents('.tasks_sort'));
            }
            return false;
        });

        /* delete button to delete a project from the list */
        $('a.delete_project_button').live('click', function(evt){
            if(confirm("Are you sure that you want to "+this.title+"?")){
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
            submit_with_ajax_and_block_element('form.edit-project-form', $(this));
            return false;
        });

        /* submit project form after entering new project */
        $("form#project_form button.positive").live('click', function (ev) {
            submit_with_ajax_and_block_element('form.#project_form', $(this));
            return false;
        });

        /* toggle new project form */
        $('#toggle_project_new').click(function(evt){
            TracksForm.toggle('toggle_project_new', 'project_new', 'project-form',
                '« Hide form', 'Hide new project form',
                'Create a new project »', 'Add a project');
        });

        /* make the three lists of project sortable */
        $(['active', 'hidden', 'completed']).each(function() {
            $("#list-"+this+"-projects").sortable({
                handle: '.handle',
                update: update_order
            });
        });
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
        context_id = $(this).parents('.container.context').get(0).id.split('c')[1];
        highlight = function(){
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
            submit: "OK",
            cancel: "CANCEL"
        });

        /* delete a context using the x button */
        $('a.delete_context_button').live('click', function(evt){
            /* TODO: move from this.title to this.x-messsage or something similar */
            if(confirm(this.title)){
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
                '« Hide form', 'Hide new context form',
                'Create a new context »', 'Add a context');
        });

        /* make the two state lists of context sortable */
        $(['active', 'hidden']).each(function() {
            $("#list-contexts-"+this).sortable({
                handle: '.handle',
                update: update_order
            })
        });
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
            if(confirm("Are you sure that you want to "+this.title+"?")){
                delete_with_ajax_and_block_element(this.href, $(this).parents('.project_notes'));
            }
            return false;
        });

        /* edit button for note */
        $('a.note_edit_settings').live('click', function(){
            dom_id = this.id.substr(10);
            $('#'+dom_id).toggle();
            $('#edit_'+dom_id).show();
            $('#edit_form_'+dom_id+' textarea').focus();
            return false;
        });

        /* cancel button when editing a note */
        $('.edit-note-form a.negative').live('click', function(){
            dom_id = this.id.substr(14);
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
            submit_with_ajax_and_block_element('form.edit-note-form', $(this));
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
    toggle_overlay: function () {
        el = document.getElementById("overlay");
        el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
    },
    setup_behavior: function() {
        /* cancel button on new recurring todo form */
        $("#recurring_todo_new_action_cancel").live('click', function(){
            $('#recurring-todo-form-new-action input:text:first').focus();
            RecurringTodosPage.hide_all_recurring();
            $('#recurring_daily').show();
            RecurringTodosPage.toggle_overlay();
        });
        /* cancel button on edit recurring todo form */
        $("#recurring_todo_edit_action_cancel").live('click', function(){
            $('#recurring-todo-form-edit-action input:text:first').focus();
            RecurringTodosPage.hide_all_recurring();
            $('#recurring_daily').show();
            RecurringTodosPage.toggle_overlay();
        });
        /* change recurring period radio input on edit form */
        $("#recurring_edit_period input").live('click', function(){
            RecurringTodosPage.hide_all_edit_recurring();
            $('#recurring_edit_'+this.id.split('_')[5]).show();
        });
        /* change recurring period radio input on new form */
        $("#recurring_period input").live('click', function(){
            RecurringTodosPage.hide_all_recurring();
            $('#recurring_'+this.id.split('_')[4]).show();
        });
        /* add new recurring todo plus-button in sidebar */
        $("#add-new-recurring-todo").live('click', function(){
            $('#new-recurring-todo').show();
            $('#edit-recurring-todo').hide();
            RecurringTodosPage.toggle_overlay();
        });
        /* submit form when editing a recurring todo */
        $("#recurring_todo_edit_action_submit").live('click', function (ev) {
            submit_with_ajax_and_block_element('form#recurring-todo-form-edit-action', $(this));
            return false;
        });
        /* submit form for new recurring todo */
        $("#recurring_todo_new_action_submit").live('click', function (ev) {
            submit_with_ajax_and_block_element('form.#recurring-todo-form-new-action', $(this));
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

/**************************************/
/* Tracks AJAX functions              */
/**************************************/

function generic_get_script_for_list(element, getter, param){
    $(element).load(relative_to_root(getter+'?'+param));
}

function default_ajax_options_for_submit(ajax_type, element_to_block) {
    options = {
        type: ajax_type,
        async: true,
        context: element_to_block,
        data: "_source_view=" + SOURCE_VIEW,
        beforeSend: function() {
            $(this).block({
                message: null
            });
        },
        complete:function() {
            $(this).unblock();
            enable_rich_interaction();
        },
        error: function(req, status) {
            TracksPages.page_notify('error', 'There was an error retrieving from server: '+status, 8);
        }
    }
    if(typeof(TAG_NAME) !== 'undefined')
        options.data += "&_tag_name="+ TAG_NAME;
    return options;
}

function default_ajax_options_for_scripts(ajax_type, the_url, element_to_block) {
    options = default_ajax_options_for_submit(ajax_type, element_to_block);
    options.url = the_url;
    options.dataType = 'script';
    return options;
}

function submit_with_ajax_and_block_element(form, element_to_block) {
    options = default_ajax_options_for_submit('POST', element_to_block);
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
    options = default_ajax_options_for_scripts('POST', the_url, element_to_block);
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
    request.setRequestHeader("Accept", "text/javascript");
});

function setup_periodic_check(url_for_check, interval_in_sec, method) {
    ajaxMethod = (method ? method : "GET");

    function check_remote() {
        $.ajax({
            type: ajaxMethod,
            url: url_for_check,
            dataType: 'script'
        });
    }
    setInterval(check_remote, interval_in_sec*1000);
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
            context_name = $(this).parents('form').find('input[name=context_name]');
            if(context_name.attr('edited') === undefined){
                context_name.val(defaultContexts[$(this).val()]);
            }
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
    /* called after completion of all AJAX calls */

    /* fix for #1036 where closing a edit form before the autocomplete was filled
     * resulted in a dropdown box that could not be removed. We remove all
     * autocomplete boxes the hard way */
    $('.ac_results').remove();

    $('input.Date').datepicker({
        'dateFormat': dateFormat,
        'firstDay': weekStart,
        'showAnim': 'fold'
    });

    /* Autocomplete */
    $('input[name=context_name]').autocomplete({
        source: relative_to_root('contexts.autocomplete'),
        selectFirst: true
    });
    $('input[name=project_name]').autocomplete({
        source: relative_to_root('projects.autocomplete'),
        selectFirst: true
    });
    $('input[name="project[default_context_name]"]').autocomplete({
        source: relative_to_root('contexts.autocomplete'),
        selectFirst: true
    });

    $('input[name=tag_list]:not(.ac_input)')
    .bind( "keydown", function( event ) { // don't navigate away from the field on tab when selecting an item
        if ( event.keyCode === $.ui.keyCode.TAB &&
            $( this ).data( "autocomplete" ).menu.active ) {
            event.preventDefault();
        }
    })
    .autocomplete({
        minLength: 0,
        source: function( request, response ) {
            last_term = extractLast( request.term );
            if (last_term != "" && last_term != " ")
                $.getJSON( relative_to_root('tags.autocomplete'), {
                    term: last_term
                }, response );
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
        },
        selectFirst: true
    });


    function split( val ) {
        return val.split( /,\s*/ );
    }
    function extractLast( term ) {
        return split( term ).pop();
    }


    /* multiple: true,
        multipleSeparator:',' */

    $('input[name=predecessor_list]:not(.ac_input)')
    .bind( "keydown", function( event ) { // don't navigate away from the field on tab when selecting an item
        if ( event.keyCode === $.ui.keyCode.TAB &&
            $( this ).data( "autocomplete" ).menu.active ) {
            event.preventDefault();
        }
    })
    .autocomplete({
        minLength: 0,
        source: function( request, response ) {
            last_term = extractLast( request.term );
            if (last_term != "" && last_term != " ")
                $.getJSON( relative_to_root('auto_complete_for_predecessor'), {
                    term: last_term
                }, response );
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

    /* Drag & Drop for successor/predecessor */
    function drop_todo(evt, ui) {
        dragged_todo = ui.draggable[0].id.split('_')[2];
        dropped_todo = this.id.split('_')[2];
        ui.draggable.remove();
        $('.drop_target').hide(); // IE8 doesn't call stop() in this situation
        $(this).block({
            message: null
        });
        $.post(relative_to_root('todos/add_predecessor'),
        {
            successor: dragged_todo,
            predecessor: dropped_todo
        },
        null, 'script');
    }

    function drag_todo(){
        $('.drop_target').show();
        $(this).parents(".container").find(".context_target").hide();
    }

    $('.item-show').draggable({
        handle: '.grip',
        revert: 'invalid',
        start: drag_todo,
        stop: function() {
            $('.drop_target').hide();
        }
    });

    $('.item-show').droppable({
        drop: drop_todo,
        tolerance: 'pointer',
        hoverClass: 'hover'
    });
  
    /* Drag & drop for changing contexts */
    function drop_todo_on_context(evt, ui) {
        target = $(this);
        dragged_todo = ui.draggable[0].id.split('_')[2];
        context_id = this.id.split('_')[1];
        ui.draggable.remove();
        target.block({
            message: null
        });
        setTimeout(function() {
            target.show()
        }, 0);
        $.post(relative_to_root('todos/change_context'),
        {
            "todo[id]": dragged_todo,
            "todo[context_id]": context_id
        },
        function(){
            target.unblock();
            target.hide();
        }, 'script');
    }

    $('.context_target').droppable({
        drop: drop_todo_on_context,
        tolerance: 'pointer',
        hoverClass: 'hover'
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
    TracksPages.setup_nifty_corners();

    TodoItemsContainer.setup_container_toggles();

    /* enable page specific behavior */
    $([ 'IntegrationsPage', 'NotesPage', 'ProjectListPage', 'ContextListPage',
        'FeedsPage', 'RecurringTodosPage', 'TodoItems', 'TracksPages',
        'TracksForm', 'SearchPage', 'UsersPage' ]).each(function() {
        eval(this+'.setup_behavior();');
    });

    /* Gets called from all AJAX callbacks, too */
    enable_rich_interaction();
});
