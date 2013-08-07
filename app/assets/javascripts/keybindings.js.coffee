$ ->
  # Hotkey binding to links with 'data-keybinding' attribute
  # Navigate link when hotkey pressed
  $('a[data-keybinding]').each (i, el) ->
    Mousetrap.bind $(el).data('keybinding'), (e) ->
      if typeof(Turbolinks) == 'undefined'
        # Emulate click if turbolinks defined
        el.click()
      else
        # Use turbolinks to go to URL
        Turbolinks.visit(el.href)

  # Hotkey binding to inputs with 'data-keybinding' attribute
  # Focus input when hotkey pressed
  $('input[data-keybinding]').each (i, el) ->
    Mousetrap.bind $(el).data('keybinding'), (e) ->
      el.focus()
      if e.preventDefault
        e.preventDefault()
      else
        e.returnValue = false

  # Toggle show/hide hotkey hints
  window.mouseTrapRails =
    showOnLoad: false           # Show/hide hotkey hints by default (on page load). Mostly for debugging purposes.
    toggleKeys: 'alt+shift+h'   # Keys combo to toggle hints visibility.
    keysShown: false
    toggleHints:  ->
      $('a[data-keybinding]').each (i, el) ->
        $el = $(el)
        if mouseTrapRails.keysShown
          $el.removeClass('mt-hotkey-el').find('.mt-hotkey-hint').remove()
        else
          mtKey = $el.data('keybinding')
          $hint = "<i class='mt-hotkey-hint' title='Press \<#{mtKey}\> to open link'>#{mtKey}</i>"
          $el.addClass('mt-hotkey-el') unless $el.css('position') is 'absolute'
          $el.append $hint
      @keysShown ^= true

  Mousetrap.bind mouseTrapRails.toggleKeys, -> mouseTrapRails.toggleHints()

  mouseTrapRails.toggleHints() if mouseTrapRails.showOnLoad

  # HELP
  Mousetrap.bind '?', -> $('div#tracks-shortcuts-dialog').modal()

  # ADD: a is bound in navbar

  # GO TO
  Mousetrap.bind 'G',   -> TracksApp.go_menu()
  Mousetrap.bind 'g h', -> TracksApp.go_home_page()
  Mousetrap.bind 'g c', -> TracksApp.go_context()
  Mousetrap.bind 'g C', -> TracksApp.go_contexts_page()
  Mousetrap.bind 'g t', -> TracksApp.go_tag()
  Mousetrap.bind 'g p', -> TracksApp.go_project()
  Mousetrap.bind 'g P', -> TracksApp.go_projects_page()
  Mousetrap.bind 'g s', -> TracksApp.go_starred_page()

  # VIEW
  Mousetrap.bind 'v p', -> TracksApp.group_view_by_project()
  Mousetrap.bind 'v c', -> TracksApp.group_view_by_context()

  # Item Selection
  Mousetrap.bind 'j', -> TracksApp.selectNext()
  Mousetrap.bind 'k', -> TracksApp.selectPrev()
  Mousetrap.bind 'n', -> TracksApp.toggleNoteOfSelectedTodo()