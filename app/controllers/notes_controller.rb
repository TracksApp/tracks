class NotesController < ApplicationController

  before_filter :set_source_view

  def index
    @all_notes = current_user.notes
    @count = @all_notes.size
    @page_title = "TRACKS::All notes"
    @source_view = 'note_list'
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
      format.m
    end
  end

  def create
    @note = current_user.notes.build
    @note.attributes = note_params

    @saved = @note.save

    respond_to do |format|
      format.js
      format.xml do
        if @saved
          head :created, :location => note_url(@note), :text => "new note with id #{@note.id}"
        else
          render_failure @note.errors.full_messages.join(', ')
        end
      end
      format.html do
        render :text => 'unexpected request for html rendering'
      end
    end
  end

  def update
    @note = current_user.notes.find(params['id'])
    @note.attributes = note_params
    @saved = @note.save
    respond_to do |format|
      format.html
      format.js { render }
    end
  end

  def destroy
    @note = current_user.notes.find(params['id'])
    @note.destroy
    set_source_view

    respond_to do |format|
      format.html
      format.js { @down_count = current_user.notes.size }
    end
  end

  protected

  def set_source_view
    @source_view = params['_source_view'] || 'note'
  end

  private

  def note_params
    params.require(:note).permit(:project_id, :body)
  end

end
