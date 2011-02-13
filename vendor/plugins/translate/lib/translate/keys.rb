require 'pathname'

class Translate::Keys
  # Allows keys extracted from lookups in files to be cached
  def self.files
    @@files ||= Translate::Keys.new.files
  end
  
  # Allows flushing of the files cache
  def self.files=(files)
    @@files = files
  end
  
  def files
    @files ||= extract_files
  end  
  alias_method :to_hash, :files
  
  def keys
    files.keys
  end
  alias_method :to_a, :keys

  def i18n_keys(locale)
    I18n.backend.send(:init_translations) unless I18n.backend.initialized?
    Translate::Keys.to_shallow_hash(I18n.backend.send(:translations)[locale.to_sym]).keys.sort
  end

  def untranslated_keys
    Translate::Keys.translated_locales.inject({}) do |missing, locale|
      missing[locale] = i18n_keys(I18n.default_locale).map do |key|
        I18n.backend.send(:lookup, locale, key).nil? ? key : nil
      end.compact
      missing
    end
  end

  def missing_keys
    locale = I18n.default_locale; yaml_keys = {}
    yaml_keys = Translate::Storage.file_paths(locale).inject({}) do |keys, path|
      keys = keys.deep_merge(Translate::File.new(path).read[locale.to_s])
    end
    files.reject { |key, file| self.class.contains_key?(yaml_keys, key) }
  end

  def self.translated_locales
    I18n.available_locales.reject { |locale| [:root, I18n.default_locale.to_sym].include?(locale) }        
  end

  # Checks if a nested hash contains the keys in dot separated I18n key.
  #
  # Example:
  #
  # hash = {
  #   :foo => {
  #     :bar => {
  #       :baz => 1
  #     }
  #   }
  # }
  #
  # contains_key?("foo", key) # => true
  # contains_key?("foo.bar", key) # => true
  # contains_key?("foo.bar.baz", key) # => true
  # contains_key?("foo.bar.baz.bla", key) # => false
  #
  def self.contains_key?(hash, key)
    keys = key.to_s.split(".")
    return false if keys.empty?
    !keys.inject(HashWithIndifferentAccess.new(hash)) do |memo, key|
      memo.is_a?(Hash) ? memo.try(:[], key) : nil
    end.nil?
  end
  
  # Convert something like:
  # 
  # {
  #  :pressrelease => {
  #    :label => {
  #      :one => "Pressmeddelande"
  #    }
  #   }
  # }
  # 
  # to:
  # 
  #  {'pressrelease.label.one' => "Pressmeddelande"}
  #
  def self.to_shallow_hash(hash)
    hash.inject({}) do |shallow_hash, (key, value)|
      if value.is_a?(Hash)
        to_shallow_hash(value).each do |sub_key, sub_value|
          shallow_hash[[key, sub_key].join(".")] = sub_value
        end
      else
        shallow_hash[key.to_s] = value
      end
      shallow_hash
    end
  end
  
  # Convert something like:
  # 
  #  {'pressrelease.label.one' => "Pressmeddelande"}
  # 
  # to:
  # 
  # {
  #  :pressrelease => {
  #    :label => {
  #      :one => "Pressmeddelande"
  #    }
  #   }
  # }
  def self.to_deep_hash(hash)    
    hash.inject({}) do |deep_hash, (key, value)|
      keys = key.to_s.split('.').reverse
      leaf_key = keys.shift
      key_hash = keys.inject({leaf_key.to_sym => value}) { |hash, key| {key.to_sym => hash} }
      deep_merge!(deep_hash, key_hash)
      deep_hash
    end
  end

  # deep_merge by Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
  def self.deep_merge!(hash1, hash2)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    hash1.merge!(hash2, &merger)
  end

  private

  def extract_files
    files_to_scan.inject(HashWithIndifferentAccess.new) do |files, file|
      IO.read(file).scan(i18n_lookup_pattern).flatten.map(&:to_sym).each do |key|
        files[key] ||= []
        path = Pathname.new(File.expand_path(file)).relative_path_from(Pathname.new(Rails.root)).to_s
        files[key] << path if !files[key].include?(path)
      end
      files
    end
  end

  def i18n_lookup_pattern
    /\b(?:I18n\.t|I18n\.translate|t)(?:\s|\():?'([a-z0-9_]+.[a-z0-9_.]+)'\)?/
  end

  def files_to_scan
    Dir.glob(File.join(Translate::Storage.root_dir, "{app,config,lib}", "**","*.{rb,erb,rhtml}")) +
      Dir.glob(File.join(Translate::Storage.root_dir, "public", "javascripts", "**","*.js"))
  end
end
