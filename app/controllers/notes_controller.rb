class NotesController < ApplicationController

  def index
    @all_notes = current_user.notes
    @count = @all_notes.size
    @page_title = "TRACKS::All notes"
    respond_to do |format|
      format.html
      format.xml { render :xml => @all_notes.to_xml( :except => :user_id )  }
    end
  end

  def show
    @note = current_user.notes.find(params['id'])
    @page_title = "TRACKS::Note " + @note.id.to_s
    respond_to do |format|
      format.html
      format.m &render_note_mobile
    end
  end

  def render_note_mobile
    lambda do
      render :action => 'note_mobile'
    end
  end

  def create
    note = current_user.notes.build
    note.attributes = params["new_note"]

    if note.save
      render :partial => 'notes_summary', :object => note
    else
      render :text => ''
    end
  end

  def destroy
    @note = current_user.notes.find(params['id'])

    @note.destroy
    
    respond_to do |format|
      format.html
      format.js do
        @count = current_user.notes.size
        render
      end
    end
      
    #    if note.destroy
    #      render :text => ''
    #    else
    #      notify :warning, "Couldn't delete note \"#{note.id}\""
    #      render :text => ''
    #    end
  end

  def update
    note = current_user.notes.find(params['id'])
    note.attributes = params["note"]
    if note.save
      render :partial => 'notes', :object => note
    else
      notify :warning, "Couldn't update note \"#{note.id}\""
      render :text => ''
    end
  end

end
