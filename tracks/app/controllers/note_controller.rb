class NoteController < ApplicationController
  
  layout "standard"
  
  def index
    @all_notes = Note.list_all
    @page_title = "TRACKS::All notes"
  end
  
  def show
    @note = Note.find(@params[:id])
    @page_title = "TRACKS::Note " + @note.id.to_s
  end
  
  # Add a new note to this project
  #
  def add_note
    
    note = Note.new
    note.attributes = @params["new_note"]

    if note.save
      render_partial 'notes_summary', note
    else
      render_text ""
    end
  end
  
  def destroy_note
    note = Note.find_by_id(@params[:id])
    if note.destroy
      render_text ""
    else
      flash["warning"] = "Couldn't delete note \"#{note.id.to_s}\""
      render_text ""
    end
  end
  
  def update_note
    note = Note.find_by_id(@params[:id])
    note.attributes = @params["note"]
      if note.save
        render_partial 'notes', note
      else
        flash["warning"] = "Couldn't update note \"#{note.id.to_s}\""
        render_text ""
      end
  end
  
end
