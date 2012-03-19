Given /^I have a local file named "([^"]*)" with:$/ do |filename, content|
  File.open(filename, 'w') {|io| io.write(content)}
end

When /^I do aruba (.*)$/ do |aruba_step|
  begin
    When(aruba_step)
  rescue => e
    @aruba_exception = e
  end
end

Then /^the output should contain the JRuby version$/ do
  pending "This must be manually run in JRuby" unless defined?(JRUBY_VERSION)
  Then %{the output should contain "#{JRUBY_VERSION}"}
end

Then /^the output should contain the current Ruby version$/ do
  Then %{the output should contain "#{RUBY_VERSION}"}
end

Then /^aruba should fail with "([^"]*)"$/ do |error_message|
  @aruba_exception.message.should =~ compile_and_escape(error_message)
end
