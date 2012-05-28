class <%= controller_class_name %>Controller < ApplicationController
  <%- if defined?(Resourceful::Maker) -%>
  make_resourceful do
    actions :all
    
    # Let's get the most use from form_for and share a single form here!
    response_for :new, :edit do
      render :template => "<%= plural_name %>/form"
    end

    response_for :create_fails, :update_fails do
      flash[:error] = "There was a problem!"
      render :template => "<%= plural_name %>/form"
    end
  end
  <%- else -%>
  # GET /<%= table_name %>
  # GET /<%= table_name %>.xml
  def index
    @<%= table_name %> = <%= class_name %>.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= table_name %> }
    end
  end

  # GET /<%= table_name %>/1
  # GET /<%= table_name %>/1.xml
  def show
    @<%= file_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/new
  # GET /<%= table_name %>/new.xml
  def new
    @<%= file_name %> = <%= class_name %>.new

    respond_to do |format|
      format.html { render :template => "<%= plural_name %>/form" }
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/1/edit
  def edit
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    render :template => "<%= plural_name %>/form"
  end

  # POST /<%= table_name %>
  # POST /<%= table_name %>.xml
  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = '<%= class_name %> was successfully created.'
        format.html { redirect_to(@<%= file_name %>) }
        format.xml  { render :xml => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
      else
        flash.now[:error] = '<%= class_name %> could not be created.'
        format.html { render :template => "<%= plural_name %>/form" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /<%= table_name %>/1
  # PUT /<%= table_name %>/1.xml
  def update
    @<%= file_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = '<%= class_name %> was successfully updated.'
        format.html { redirect_to(@<%= file_name %>) }
        format.xml  { head :ok }
      else
        flash.now[:error] = '<%= class_name %> could not be created.'
        format.html { render :template => "<%= plural_name %>/form" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= table_name %>/1
  # DELETE /<%= table_name %>/1.xml
  def destroy
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    @<%= file_name %>.destroy

    respond_to do |format|
      flash[:notice] = '<%= class_name %> was successfully deleted.'
      format.html { redirect_to(<%= table_name %>_url) }
      format.xml  { head :ok }
    end
  end
  <%- end -%>
end
