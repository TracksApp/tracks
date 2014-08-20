class SearchController < ApplicationController

  helper :todos, :application, :notes, :projects, :contexts

  def results
    @source_view = params['_source_view'] || 'search'
    @page_title = "TRACKS::Search Results for #{params[:search]}"

    searcher = Search::SearchResults.new(current_user, params[:search])
    searcher.search

    @results = searcher.results
    @count = searcher.number_of_finds

    init_not_done_counts
    init_project_hidden_todo_counts
  end

  def index
    @page_title = "TRACKS::Search"
  end
end
