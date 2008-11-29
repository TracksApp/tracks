namespace :tracks do
  desc 'Replace the password of USER with a new one.'
  task :password => :environment do
    
    Dependencies.load_paths.unshift(File.dirname(__FILE__) + "/../../vendor/gems/highline-1.5.0/lib")
    require "highline/import"
    
    user = User.find_by_login(ENV['USER'])
    if user.nil?
      puts "Sorry, we couldn't find user '#{ENV['USER']}'. To specify a different user, pass USER=username to this task."
      exit 0
    end 
    
    puts "Changing Tracks password for #{ENV['USER']}."
    password = ask("New password: ") { |q| q.echo = false }
    password_confirmation = ask('Retype new password: ') { |q| q.echo = false }
    
    begin
      user.change_password(password, password_confirmation)
    rescue ActiveRecord::RecordInvalid
      puts "Sorry, we couldn't change #{ENV['USER']}'s password: "
      user.errors.each_full { |msg| puts "- #{msg}\n" }
    end
  end
end
