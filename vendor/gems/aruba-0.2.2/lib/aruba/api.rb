require 'tempfile'
require 'rbconfig'

module Aruba
  module Api
    def in_current_dir(&block)
      _mkdir(current_dir)
      Dir.chdir(current_dir, &block)
    end

    def current_dir
      File.join(*dirs)
    end

    def cd(dir)
      dirs << dir
      raise "#{current_dir} is not a directory." unless File.directory?(current_dir)
    end

    def dirs
      @dirs ||= ['tmp/aruba']
    end

    def create_file(file_name, file_content, check_presence = false)
      in_current_dir do
        raise "expected #{file_name} to be present" if check_presence && !File.file?(file_name)
        _mkdir(File.dirname(file_name))
        File.open(file_name, 'w') { |f| f << file_content }
      end
    end

    def append_to_file(file_name, file_content)
      in_current_dir do
        File.open(file_name, 'a') { |f| f << file_content }
      end
    end

    def create_dir(dir_name)
      in_current_dir do
        _mkdir(dir_name)
      end
    end

    def check_file_presence(paths, expect_presence)
      in_current_dir do
        paths.each do |path|
          if expect_presence
            File.should be_file(path)
          else
            File.should_not be_file(path)
          end
        end
      end
    end

    def check_file_content(file, partial_content, expect_match)
      regexp = compile_and_escape(partial_content)
      in_current_dir do
        content = IO.read(file)
        if expect_match
          content.should =~ regexp
        else
          content.should_not =~ regexp
        end
      end
    end
  
    def check_exact_file_content(file, exact_content)
      in_current_dir do
        IO.read(file).should == exact_content
      end
    end
  
    def check_directory_presence(paths, expect_presence)
      in_current_dir do
        paths.each do |path|
          if expect_presence
            File.should be_directory(path)
          else
            File.should_not be_directory(path)
          end
        end
      end
    end

    def _mkdir(dir_name)
      FileUtils.mkdir_p(dir_name) unless File.directory?(dir_name)
    end

    def unescape(string)
      eval(%{"#{string}"})
    end

    def compile_and_escape(string)
      Regexp.compile(Regexp.escape(string))
    end

    def combined_output
      @last_stdout + (@last_stderr == '' ? '' : "\n#{'-'*70}\n#{@last_stderr}")
    end

    def assert_partial_output(partial_output)
      combined_output.should =~ compile_and_escape(partial_output)
    end

    def assert_passing_with(partial_output)
      assert_exit_status_and_partial_output(true, partial_output)
    end

    def assert_failing_with(partial_output)
      assert_exit_status_and_partial_output(false, partial_output)
    end

    def assert_exit_status_and_partial_output(expect_to_pass, partial_output)
      assert_partial_output(partial_output)
      if expect_to_pass
        @last_exit_status.should == 0
      else
        @last_exit_status.should_not == 0
      end
    end
    
    def install_gems(gemfile)
      create_file("Gemfile", gemfile)
      if ENV['GOTGEMS'].nil?
        run("gem install bundler")
        run("bundle --no-color install")
      end
    end

    def run(cmd, fail_on_error=true)
      cmd = detect_ruby(cmd)

      stderr_file = Tempfile.new('cucumber')
      stderr_file.close
      in_current_dir do
        announce_or_puts("$ cd #{Dir.pwd}") if @announce_dir
        announce_or_puts("$ #{cmd}") if @announce_cmd

        mode = RUBY_VERSION =~ /^1\.9/ ? {:external_encoding=>"UTF-8"} : 'r'
        
        IO.popen("#{cmd} 2> #{stderr_file.path}", mode) do |io|
          @last_stdout = io.read
          announce_or_puts(@last_stdout) if @announce_stdout
        end

        @last_exit_status = $?.exitstatus
      end
      @last_stderr = IO.read(stderr_file.path)

      announce_or_puts(@last_stderr) if @announce_stderr

      if(@last_exit_status != 0 && fail_on_error)
        fail("Exit status was #{@last_exit_status}. Output:\n#{combined_output}")
      end

      @last_stderr
    end

    def announce_or_puts(msg)
      if(@puts)
        puts(msg)
      else
        announce(msg)
      end
    end

    def detect_ruby(cmd)
      if cmd =~ /^ruby\s/
        cmd.gsub(/^ruby\s/, "#{current_ruby} ")
      else
        cmd
      end
    end

    def current_ruby
      File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
    end

    def use_clean_gemset(gemset)
      run(%{rvm gemset create "#{gemset}"}, true)
      if @last_stdout =~ /'#{gemset}' gemset created \((.*)\)\./
        gem_home = $1
        set_env('GEM_HOME', gem_home)
        set_env('GEM_PATH', gem_home)
        set_env('BUNDLE_PATH', gem_home)

        paths = (ENV['PATH'] || "").split(File::PATH_SEPARATOR)
        paths.unshift(File.join(gem_home, 'bin'))
        set_env('PATH', paths.uniq.join(File::PATH_SEPARATOR))

        run("gem install bundler", true)
      else
        raise "I didn't understand rvm's output: #{@last_stdout}"
      end
    end

    def unset_bundler_env_vars
      %w[RUBYOPT BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE].each do |key|
        set_env(key, nil)
      end
    end

    def set_env(key, value)
      announce_or_puts(%{$ export #{key}="#{value}"}) if @announce_env
      original_env[key] = ENV.delete(key)
      ENV[key] = value
    end

    def restore_env
      original_env.each do |key, value|
        ENV[key] = value
      end
    end
    
    def original_env
      @original_env ||= {}
    end
  end
end
