module NotesHelper
  def truncated_note(note, characters = 50)
    sanitize(textilize_without_paragraph(truncate(note.body, :length => characters, :omission => "...")))
  end

  def rendered_note(note)
    sanitize(textilize_without_paragraph(note.body))
  end

  def link_to_delete_note(note, descriptor = sanitize(note.id.to_s))
    link_to(
      descriptor,
      note_path(note, :format => 'js'),
      {:id => "delete_note_#{note.id}", :class => "delete_note_button",
        :title => t('notes.delete_note_title', :id => note.id), :x_confirm_message => t('notes.delete_note_confirm', :id => note.id)}
    )
  end

end
