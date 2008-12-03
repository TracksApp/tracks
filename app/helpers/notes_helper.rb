module NotesHelper
  def truncated_note(note, characters = 50)
    sanitize(textilize_without_paragraph(truncate(note.body, :length => characters, :omission => "...")))
  end
end
