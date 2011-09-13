AfterStep('@pause') do
  print "Press Return to continue..."
  STDIN.getc
end

Before('@clear_cookies') do
  cookies = selenium.cookies
  cookies.split(';').each do | cookie |
    selenium.delete_cookie(cookie)
  end
end
