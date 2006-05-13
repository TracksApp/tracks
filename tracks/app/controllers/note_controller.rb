class NoteController < ApplicationController

  model :user
  before_filter :login_required

  layout "standard"

  def index
    @all_notes = @user.notes
    @page_title = "TRACKS::All notes"
  end

  def show
    @note = check_user_return_note
    @page_title = "TRACKS::Note " + @note.id.to_s
  end

  # Add a new note to this project
  #
  def add
    note = @user.notes.build
    note.attributes = params["new_note"]

    if note.save
      render_partial 'notes_summary', note
    else
      render_text ""
    end
  end

  def delete
    note = check_user_return_note
    if note.destroy
      render_text ""
    else
      flash["warning"] = "Couldn't delete note \"#{note.id.to_s}\""
      render_text ""
    end
  end

  def update
    note = check_user_return_note
    note.attributes = params["note"]
      if note.save
        render_partial 'notes', note
      else
        flash["warning"] = "Couldn't update note \"#{note.id.to_s}\""
        render_text ""
      end
  end

  protected

    def check_user_return_note
      note = Note.find_by_id( params['id'] )
      if @user == note.user
        return note
      else
        render_text ""
      end
    end
end
