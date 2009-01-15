require File.dirname(__FILE__) + '/../../spec_helper'

describe "/login.m" do
  it "should render without an error" do
    render :action => 'login/login_mobile.html.erb', :layout => 'mobile.m.erb'
    response.should_not have_tag("div#Application-Trace")
  end
end
