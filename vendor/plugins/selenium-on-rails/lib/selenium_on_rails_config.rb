require 'yaml'

class SeleniumOnRailsConfig
  attr_accessor :configs
  
  def initialize
    @defaults = {:environments => ['test']}
    initialize_configs
  end
  
  def get var, default = nil
    value = @configs[var.to_s]
    value ||= @defaults[var]
    value ||= default
    value ||= yield if block_given?
    value
  end
  
  def initialize_configs
    @configs = {}
    files = [File.expand_path(File.dirname(__FILE__) + '/../config.yml')]
    files << File.join(RAILS_ROOT, 'config', 'selenium.yml')
    files.each { |file| @configs = YAML.load_file(file) if File.exist?(file) }
  end

end