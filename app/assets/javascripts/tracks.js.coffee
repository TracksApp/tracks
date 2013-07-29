# Tracks specific coffeescript

TracksApp =
    goto_page:   (page) -> window.location.href = page
    go_home:     -> TracksApp.goto_page "/"
    go_contexts: -> TracksApp.goto_page "/contexts"
    go_projects: -> TracksApp.goto_page "/projects"
    go_starred:  -> TracksApp.goto_page "/tag/starred"

    # TODO: refactor to work for contexts and projects and tags
    go_project:  ->         
        $("input#tracks-goto-project").val("")
        $('div#tracks-go-project-dialog').on 'shown', -> $("input#tracks-goto-project").focus()
        $('div#tracks-go-project-dialog').modal()

    go_menu:     -> $('div#tracks-goto-dialog').modal()
    add_todo:    -> $('div#tracks-add-action-dialog').modal()

    createSubmenu: (todo, itemToAddBefore) ->
        template_clone = $("div.todo-sub-menu-template").clone()
        itemToAddBefore.before(template_clone)
        todo_menu = todo.find("div.todo-sub-menu-template")
        todo_menu.removeClass("todo-sub-menu-template")
        todo_menu.addClass("todo-sub-menu")
        todo_menu.removeClass("hide")

    appendTodoSubMenu: (todo) ->
        if todo.find("div.todo-sub-menu").length is 0
            notes_row = todo.find(".todo-notes").parent()
            submenu = TracksApp.createSubmenu(todo, notes_row)
        else
            todo.find("div.todo-sub-menu").removeClass("hide")

    selectTodo: (new_todo) ->
        selected_item = $("div.todo-item.selected-item")
        selected_item.find("div.todo-sub-menu").addClass("hide")
        selected_item.find("span.todo-item-detail").addClass("hide")
        selected_item.removeClass("selected-item")
        TracksApp.appendTodoSubMenu(new_todo)
        new_todo.find("span.todo-item-detail").removeClass("hide")
        new_todo.addClass("selected-item")

    selectPrevNext: (go_next) ->
        current = prev = next = null
        stop = false
        $("div.todo-item").each ->
            if stop
                next = $(this)
                return false

            prev = current
            current = $(this) 

            if $(this).hasClass("selected-item")
                stop = true
        
        if go_next 
            TracksApp.selectTodo(prev) if prev?
            return prev
        else
            TracksApp.selectTodo(next) if next?
            return next
    
    selectPrev: ->
        unless TracksApp.selectPrevNext(true)?
            TracksApp.selectTodo($("div.todo-item").last())
    
    selectNext: ->
        unless TracksApp.selectPrevNext(false)?
            TracksApp.selectTodo($("div.todo-item").first())

    show_note: (node) ->
        notes_id = node.attr("data-note-id")
        notes_div = $("div#" + notes_id )
        notes_div.toggleClass("hide")
        todo_item = $(this).parent().parent().parent().parent().parent()
        TracksApp.selectTodo(todo_item)

    refresh_page: ->
        location.reload(true)

    group_view_by: (state) ->
        $.cookie('group_view_by', state)

    group_view_by_context: ->
        TracksApp.group_view_by('context')
        TracksApp.refresh_page()

    group_view_by_project: ->
        TracksApp.group_view_by('project')
        TracksApp.refresh_page()


# Make TracksApp globally accessible. From http://stackoverflow.com/questions/4214731/coffeescript-global-variables
root = exports ? this
root.TracksApp = TracksApp

$ ->
    $("a#menu-keyboard-shotcuts").click             -> $('div#tracks-shortcuts-dialog').modal()
    $("a.button-add-todo").click                    -> TracksApp.add_todo()
    $("a.button-home").click                        -> TracksApp.go_home()
    $("a.button-goto").click                        -> TracksApp.go_menu()
    $("i.icon-book").click                          -> TracksApp.show_note( $(this) )
    $("span.todo-item-description-container").click -> TracksApp.selectTodo( $(this).parent().parent().parent() )

    $('.ajax-typeahead').typeahead
        minLength: 2, 
        source: (query, process) -> 
            typeaheadURL = $(this)[0].$element[0].dataset.link
            return $.ajax
                url: typeaheadURL,
                type: 'get',
                data: {"query": query},
                dataType: 'json',
                success: (json) ->
                    $("input#tracks-json-result").val(json)
                    map = $.map json, (data, item) -> data.value
                    return process(map)