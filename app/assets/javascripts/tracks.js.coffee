# Tracks specific coffeescript
# TracksApp = 
# 	goto_page:   (page) -> window.location.href = page
# 	go_home: 	 this.goto_page "/"
# 	go_contexts: this.goto_page "/contexts"
# 	go_projects: this.goto_page "/projects"

TracksApp =

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

# Make TracksApp globally accessible. From http://stackoverflow.com/questions/4214731/coffeescript-global-variables
root = exports ? this
root.TracksApp = TracksApp

$ ->
	$("a#menu-keyboard-shotcuts").click -> $('div#tracks-shortcuts-dialog').modal()

	$("a.button-add-todo").click -> $('div#tracks-add-action-dialog').modal()

	$("i.icon-book").click -> 
		notes_id = $( this ).attr("data-note-id")
		notes_div = $("div#" + notes_id )
		notes_div.toggleClass("hide")
		todo_item = $(this).parent().parent().parent().parent()
		TracksApp.selectTodo(todo_item)

	$("span.todo-item-description-container").click ->
		TracksApp.selectTodo( $(this).parent().parent().parent() )