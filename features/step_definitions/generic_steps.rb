Then "the badge should show (.*)" do |number|
  badge = -1
  response.should have_xpath("//span[@id='badge_count']") do |node|
    badge = node.first.content.to_i
  end
  badge.should == number.to_i
end
