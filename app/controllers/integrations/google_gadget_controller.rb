class Integrations::GoogleGadgetController < ApplicationController
  skip_before_filter :login_required

  def google_gadget
    render :layout => false, :content_type => Mime::XML
  end
end
