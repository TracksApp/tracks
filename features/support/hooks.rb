AfterStep('@pause') do
  print "Press Return to continue..."
  STDIN.getc
end

Before('@aruba') do
	@aruba_timeout_seconds = 10
	# print "\nsetting timeout for aruba to #{@aruba_timeout_seconds}\n"
end
