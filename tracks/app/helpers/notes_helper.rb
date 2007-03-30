module NotesHelper
  def truncated_note(note, characters = 50)
    sanitize(textilize(truncate(note.body, characters, "...")))
  end
end
