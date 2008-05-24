desc "Updates sqlite/sqlite3 databases created under Tracks 1.03 to the format required for Tracks 1.04. After this is done, you should be able to keep up to date with changes in the schema by running rake db:migrate."
task :upgrade_sqlite_db => :environment do
  # Change the three lines below appropriately for your setup
  old_db = "tracks_103.db"
  new_db = "tracks_104.db"
  cmd = "sqlite3"
  replace_string = "update todos set done='f' where done=0;\nupdate todos set done='t' where done=1;\nupdate contexts set hide='f' where hide=0;\nupdate contexts set hide='t' where hide=1;\nupdate projects set done='f' where done=0;\nupdate projects set done='t' where done=1;\nCREATE TABLE 'schema_info' (\n  'version' INTEGER default NULL\n);\nINSERT INTO \"schema_info\" VALUES(1);\nCOMMIT;"
  
  # cd to the db directory
  cd("db") do
    # Dump the old db into the temp file and replace the tinyints with booleans
    `#{cmd} #{old_db} .dump | sed "s/tinyint(4) NOT NULL default '0'/boolean default 'f'/" > temp.sql`
    # Create a second sqldump file for writing
    sqldump = File.open("temp2.sql", "w+")
    File.open("temp.sql") do |file|
      file.each_line do |line|
        # If COMMIT is on the line, insert the replace string
        # else just write the line back in
        # This effectively replaces COMMIT with the replace string
        if /COMMIT/ =~ line
          sqldump.write replace_string
        else
          sqldump.write line
        end
      end
      sqldump.close
    end
    
    # Read the second dump back in to a new db
    system "#{cmd} #{new_db} < temp2.sql"
    puts "Created the a new database called #{new_db}."
    # Clean up the temp files
    rm("temp.sql")
    rm("temp2.sql")
    puts "Temporary files cleaned up."
  end
  
  # rake db:migrate
  puts "Now check the database and run 'rake db:migrate' in the root of your Tracks installation."
end