desc "Initialises the installation, copy the *.tmpl files and directories to versions named without the .tmpl extension. It won't overwrite the files and directories if you've already copied them. You need to manually copy database.yml.tmpl -> database.yml and fill in the details before you run this task."
task :setup_tracks => :environment do
  # Check the root directory for template files
  FileList["*.tmpl"].each do |template_file|
    f = File.basename(template_file) # with suffix
    f_only = File.basename(template_file,".tmpl") # without suffix
    if File.exists?(f_only)
      puts f_only + " already exists"
    else
      cp_r(f, f_only)
      puts f_only + " created"
    end
  end

end