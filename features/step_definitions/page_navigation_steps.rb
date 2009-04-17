Then /^I should be redirected to (.+?)$/ do |page_name|
  request.headers['HTTP_REFERER'].should_not be_nil
  request.headers['HTTP_REFERER'].should_not == request.request_uri
  
  Then "I should be on #{page_name}"
end