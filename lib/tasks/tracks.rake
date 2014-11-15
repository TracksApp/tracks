namespace :tracks do
  desc 'Replace the password of USER with a new one.'
  task :password => :environment do
    require "io/console"
    
    user = User.find_by_login(ENV['USER'])
    if user.nil?
      puts "Sorry, we couldn't find user '#{ENV['USER']}'. To specify a different user, pass USER=username to this task."
      exit 0
    end 
    
    puts "Changing Tracks password for #{ENV['USER']}."
    print "New password: "
    password = STDIN.noecho(&:gets).chomp
    print "\nRetype new password: "
    password_confirmation = STDIN.noecho(&:gets).chomp
    puts
    
    begin
      user.change_password(password, password_confirmation)
      puts "Password changed."
    rescue ActiveRecord::RecordInvalid
      puts "Sorry, we couldn't change #{ENV['USER']}'s password: "
      user.errors.full_messages.each { |msg| puts "- #{msg}\n" }
    end
  end
end

