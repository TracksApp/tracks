module NotesHelper
  def truncated_note(note, characters = 50)
    sanitize(textilize_without_paragraph(truncate(note.body, characters, "...")))
  end
end
