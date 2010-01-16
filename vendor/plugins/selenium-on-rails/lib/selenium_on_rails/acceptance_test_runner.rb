$: << File.expand_path(File.dirname(__FILE__) + "/")
$: << File.expand_path(File.dirname(__FILE__) + "/../")
require 'paths'
require 'net/http'
require 'tempfile'


def c(var, default = nil) SeleniumOnRailsConfig.get var, default end
def c_b(var, default = nil) SeleniumOnRailsConfig.get(var, default) { yield } end

BROWSERS =              c :browsers, {}
REUSE_EXISTING_SERVER = c :reuse_existing_server, true
START_SERVER =          c :start_server, false  #TODO can't get it to work reliably on Windows, perhaps it's just on my computer, but I leave it off by default for now
HOST =                  c :host, 'localhost'
PORTS =                 c(:port_start, 3000)..c(:port_end, 3005)
BASE_URL_PATH =         c :base_url_path, '/'
TEST_RUNNER_URL =       c :test_runner_url, '/selenium/TestRunner.html'
MAX_BROWSER_DURATION =  c :max_browser_duration, 2*60
MULTI_WINDOW =          c :multi_window, false
SERVER_COMMAND =      c_b :server_command do
  server_path = File.expand_path(File.dirname(__FILE__) + '/../../../../../script/server')
  if RUBY_PLATFORM =~ /mswin/
    "ruby #{server_path} webrick -p %d -e test > NUL 2>&1"
  else
    # don't use redirects to /dev/nul since it makes the fork return wrong pid
    # see UnixSubProcess
    "#{server_path} webrick -p %d -e test"
  end
end

module SeleniumOnRails
  class AcceptanceTestRunner
    include SeleniumOnRails::Paths
  
    def run
      raise 'no browser specified, edit/create config.yml' if BROWSERS.empty?
      start_server
      has_error = false
      begin
        BROWSERS.each_pair do |browser, path|
          log_file = start_browser browser, path
          wait_for_completion log_file
          stop_browser
          result = YAML::load_file log_file
          print_result result
          has_error ||= result['numTestFailures'].to_i > 0
          # File.delete log_file unless has_error
        end
      rescue
        stop_server
        raise
      end
      stop_server
      raise 'Test failures' if has_error
    end
    
    private
      def start_server
        PORTS.each do |p|
          @port = p
          case server_check
            when :success
              return if REUSE_EXISTING_SERVER
              next
            when Fixnum
              next
            when :no_response
              next unless START_SERVER
              do_start_server
              return
          end
        end
        raise START_SERVER ? 'failed to start server': 'failed to find existing server, run script/server -e test'
      end
      
      def do_start_server
        puts 'Starting server'
        @server = start_subprocess(format(SERVER_COMMAND, @port))
        while true
          print '.'
          r = server_check
          if r == :success
            puts
            return
          end
          raise "server returned error: #{r}" if r.instance_of? Fixnum
          sleep 3
        end
      end
    
      def server_check
        begin
          res = Net::HTTP.get_response HOST, TEST_RUNNER_URL, @port
          return :success if (200..399).include? res.code.to_i
          return res.code.to_i
        rescue Errno::ECONNREFUSED
          return :no_response
        end
      end
    
      def stop_server
        return unless defined? @server
        puts
        @server.stop 'server'
      end
    
      def start_browser browser, path
        puts
        puts "Starting #{browser}"
        base_url = "http://#{HOST}:#{@port}#{BASE_URL_PATH}"
        log = log_file browser
        command = "\"#{path}\" \"http://#{HOST}:#{@port}#{TEST_RUNNER_URL}?test=tests&auto=true&baseUrl=#{base_url}&resultsUrl=postResults/#{log}&multiWindow=#{MULTI_WINDOW}\""
        @browser = start_subprocess command    
        log_path log
      end
      
      def stop_browser
        @browser.stop 'browser'
      end
      
      def start_subprocess command
        if RUBY_PLATFORM =~ /mswin/
          SeleniumOnRails::AcceptanceTestRunner::Win32SubProcess.new command
        elsif RUBY_PLATFORM =~ /darwin/i && command =~ /safari/i
          SeleniumOnRails::AcceptanceTestRunner::SafariSubProcess.new command
        else
          SeleniumOnRails::AcceptanceTestRunner::UnixSubProcess.new command
        end
      end
      
      def log_file browser
        FileUtils.mkdir_p(log_path(''))
        (0..100).each do |i|
          name = browser + (i==0 ? '' : "(#{i})") + '.yml'
          return name unless File.exist?(log_path(name))
        end
        raise 'there are way too many files in the log directory...'
      end
    
      def wait_for_completion log_file
        duration = 0
        while true
          raise 'browser takes too long' if duration > MAX_BROWSER_DURATION
          print '.'
          break if File.exist? log_file
          sleep 5
          duration += 5
        end
        puts
      end
    
      def print_result result
        puts "Finished in #{result['totalTime']} seconds."
        puts
        puts "#{result['numTestPasses']} tests passed, #{result['numTestFailures']} tests failed"
        puts "(Results stored in '#{result['resultDir']}')" if result['resultDir']
      end
        
  end
end

class SeleniumOnRails::AcceptanceTestRunner::SubProcess
  def stop what
    begin
      puts "Stopping #{what} (pid=#{@pid}) ..."
      Process.kill 9, @pid
    rescue Errno::EPERM #such as the process is already closed (tabbed browser)
    end
  end
end

class SeleniumOnRails::AcceptanceTestRunner::Win32SubProcess < SeleniumOnRails::AcceptanceTestRunner::SubProcess
  def initialize command
    require 'win32/open3' #win32-open3 http://raa.ruby-lang.org/project/win32-open3/

    puts command
    input, output, error, @pid = Open4.popen4 command, 't', true
  end
end

class SeleniumOnRails::AcceptanceTestRunner::UnixSubProcess < SeleniumOnRails::AcceptanceTestRunner::SubProcess
  def initialize command
    puts command
    @pid = fork do
      # Since we can't use shell redirects without screwing 
      # up the pid, we'll reopen stdin and stdout instead
      # to get the same effect.
      [STDOUT,STDERR].each {|f| f.reopen '/dev/null', 'w' }
      exec command
    end
  end
end

# The path to Safari should look like this: /Applications/Safari.app/Contents/MacOS/Safari
class SeleniumOnRails::AcceptanceTestRunner::SafariSubProcess < SeleniumOnRails::AcceptanceTestRunner::UnixSubProcess
  def initialize command
    f = File.open(Tempfile.new('selenium-on-rails').path, 'w')
    f.puts <<-HTML
      <html>
        <head>
          <script type="text/javascript" charset="utf-8">
            window.location.href = #{command.split.last};
          </script>
        </head>
        <body></body>
      </html>
    HTML
    f.close
    
    super "#{command.split.first} #{f.path}"
   end
  
end
  
