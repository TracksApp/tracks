class Integrations::ApplescriptController < ApplicationController

  def get_quicksilver_applescript
    get_applescript('quicksilver_applescript')
  end

  def get_applescript1
    get_applescript('applescript1')
  end

  def get_applescript2
    get_applescript('applescript2')
  end

  private

  def get_applescript(partial_name)
    context = current_user.contexts.find params[:context_id]
    render :partial => partial_name, :locals => { :context => context }
  end

end
