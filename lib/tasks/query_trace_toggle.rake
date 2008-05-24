namespace :query_trace do
  desc "Enables the query_trace plugin. Must restart server to take effect."
  task :on => :environment do
    unless File.exist?("#{RAILS_ROOT}/vendor/query_trace.tar.gz")
      Dir.chdir("#{RAILS_ROOT}/vendor") do
        url = "https://terralien.devguard.com/svn/projects/plugins/query_trace"
        puts "Loading query_trace from #{url}..."
        system "svn co #{url} query_trace"
        system "tar zcf query_trace.tar.gz --exclude=.svn query_trace"
        FileUtils.rm_rf("query_trace")
      end
    end
    Dir.chdir("#{RAILS_ROOT}/vendor/plugins") do
      system "tar zxf ../query_trace.tar.gz query_trace"
    end
    puts "QueryTrace plugin enabled. Must restart server to take effect."
  end

  desc "Disables the query_trace plugin. Must restart server to take effect."
  task :off => :environment do
    FileUtils.rm_rf("#{RAILS_ROOT}/vendor/plugins/query_trace")
    puts "QueryTrace plugin disabled. Must restart server to take effect."
  end
end

namespace :query_analyzer do
  desc "Enables the query_analyzer plugin. Must restart server to take effect."
  task :on => :environment do
    unless File.exist?("#{RAILS_ROOT}/vendor/query_analyzer.tar.gz")
      Dir.chdir("#{RAILS_ROOT}/vendor") do
        url = "http://svn.nfectio.us/plugins/query_analyzer"
        puts "Loading query_analyzer from #{url}..."
        system "svn co #{url} query_analyzer"
        system "tar zcf query_analyzer.tar.gz --exclude=.svn query_analyzer"
        FileUtils.rm_rf("query_analyzer")
      end
    end
    Dir.chdir("#{RAILS_ROOT}/vendor/plugins") do
      system "tar zxf ../query_analyzer.tar.gz query_analyzer"
    end
    puts "QueryAnalyzer plugin enabled. Must restart server to take effect."
  end

  desc "Disables the query_analyzer plugin. Must restart server to take effect."
  task :off => :environment do
    FileUtils.rm_rf("#{RAILS_ROOT}/vendor/plugins/query_analyzer")
    puts "QueryAnalyzer plugin disabled. Must restart server to take effect."
  end
end

