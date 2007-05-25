require 'ruby-debug'
Debugger.start

class TaggingGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false
  default_options :self_referential => false
  attr_reader :parent_association_name
  attr_reader :taggable_models

  def initialize(runtime_args, runtime_options = {})
    @parent_association_name = (runtime_args.include?("--self-referential") ? "tagger" : "tag")
    @taggable_models = runtime_args.reject{|opt| opt =~ /^--/}.map do |taggable|
      ":" + taggable.underscore.pluralize
    end
    @taggable_models += [":tags"] if runtime_args.include?("--self-referential") 
    @taggable_models.uniq!

    hacks    
 
    runtime_args.unshift("placeholder")
    super
  end
  
  def hacks    
    # add the extension require in environment.rb
    phrase = "require 'tagging_extensions'"
    filename = "#{RAILS_ROOT}/config/environment.rb"
    unless (open(filename) do |file|
      file.grep(/#{Regexp.escape phrase}/).any?
    end)
      open(filename, 'a+') do |file|
        file.puts "\n" + phrase + "\n"
      end
    end
  end
  
  def manifest
    record do |m|
      m.class_collisions class_path, class_name, "#{class_name}Test"

      m.directory File.join('app/models', class_path)
      m.directory File.join('test/unit', class_path)
      m.directory File.join('test/fixtures', class_path)
      m.directory File.join('test/fixtures', class_path)
      m.directory File.join('lib')

      m.template 'tag.rb', File.join('app/models', class_path, "tag.rb")
      m.template 'tag_test.rb', File.join('test/unit', class_path, "tag_test.rb")
      m.template 'tags.yml', File.join('test/fixtures', class_path, "tags.yml")
      
      m.template 'tagging.rb', File.join('app/models', class_path, "tagging.rb")
      m.template 'tagging_test.rb', File.join('test/unit', class_path, "tagging_test.rb")
      m.template 'taggings.yml', File.join('test/fixtures', class_path, "taggings.yml")
      
      m.template 'tagging_extensions.rb', File.join('lib', 'tagging_extensions.rb')

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate',
          :migration_file_name => "create_tags_and_taggings"
      end
      
    end
  end

  protected
    def banner
      "Usage: #{$0} generate tagging [TaggableModelA TaggableModelB ...]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration", 
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
      opt.on("--self-referential",
             "Allow tags to tag themselves.") { |v| options[:self_referential] = v }
    end
end
