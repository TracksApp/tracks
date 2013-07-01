# Tracks specific coffeescript
# TracksApp = 
# 	goto_page:   (page) -> window.location.href = page
# 	go_home: 	 this.goto_page "/"
# 	go_contexts: this.goto_page "/contexts"
# 	go_projects: this.goto_page "/projects"

TracksApp =
	currentPosition: 0

	updateCurrentPosition: ->
		this.currentPosition = 0
		$("div.todo-item").each ->
			if $(this).hasClass("selected-item")
				return false
			else
				this.currentPosition++

	selectTodo: (new_todo) ->
		$("div.todo-item.selected-item").removeClass("selected-item")
		new_todo.addClass("selected-item")
		TracksApp.updateCurrentPosition()

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

	$("div.todo-item-description-container").click ->
		TracksApp.selectTodo( $(this).parent().parent().parent() )