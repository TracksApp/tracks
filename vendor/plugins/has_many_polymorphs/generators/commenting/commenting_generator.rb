
class CommentingGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false
  default_options :self_referential => false
  attr_reader :parent_association_name
  attr_reader :commentable_models

  def initialize(runtime_args, runtime_options = {})
    @parent_association_name = (runtime_args.include?("--self-referential") ? "commenter" : "comment")
    @commentable_models = runtime_args.reject{|opt| opt =~ /^--/}.map do |commentable|
      ":" + commentable.underscore.pluralize
    end
    @commentable_models += [":comments"] if runtime_args.include?("--self-referential") 
    @commentable_models.uniq!
        
    verify @commentable_models
    hacks     
    runtime_args.unshift("placeholder")
    super
  end
  
  def verify models
    puts "** Warning: only one commentable model specified; tests may not run properly." if models.size < 2
    models.each do |model|
      model = model[1..-1].classify
      next if model == "Comment" # don't load ourselves when --self-referential is used
      self.class.const_get(model) rescue puts "** Error: model #{model[1..-1].classify} could not be loaded." or exit
    end
  end
  
  def hacks    
    # add the extension require in environment.rb
    phrase = "require 'commenting_extensions'"
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

      m.template 'comment.rb', File.join('app/models', class_path, "comment.rb")
      m.template 'comment_test.rb', File.join('test/unit', class_path, "comment_test.rb")
      m.template 'comments.yml', File.join('test/fixtures', class_path, "comments.yml")
      
      m.template 'commenting.rb', File.join('app/models', class_path, "commenting.rb")
      m.template 'commenting_test.rb', File.join('test/unit', class_path, "commenting_test.rb")
      m.template 'commentings.yml', File.join('test/fixtures', class_path, "commentings.yml")
      
      m.template 'commenting_extensions.rb', File.join('lib', 'commenting_extensions.rb')

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate',
          :migration_file_name => "create_comments_and_commentings"
      end
      
    end
  end

  protected
    def banner
      "Usage: #{$0} generate commenting [CommentableModelA CommentableModelB ...]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration", 
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
      opt.on("--self-referential",
             "Allow comments to comment themselves.") { |v| options[:self_referential] = v }
    end
    
    # Useful for generating tests/fixtures
    def model_one
      commentable_models[0][1..-1].classify
    end
    
    def model_two
      commentable_models[1][1..-1].classify rescue model_one
    end
end
