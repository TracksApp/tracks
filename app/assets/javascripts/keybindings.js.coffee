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

