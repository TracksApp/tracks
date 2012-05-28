class TranslateController < ActionController::Base
  # It seems users with active_record_store may get a "no :secret given" error if we don't disable csrf protection,
  skip_before_filter :verify_authenticity_token

  prepend_view_path(File.join(File.dirname(__FILE__), "..", "views"))
  layout 'translate'

  before_filter :init_translations
  before_filter :set_locale
  
  def index
    initialize_keys
    filter_by_key_pattern
    filter_by_text_pattern
    filter_by_translated_or_changed
    sort_keys
    paginate_keys
    @total_entries = @keys.size
  end
  
  def translate
    I18n.backend.store_translations(@to_locale, Translate::Keys.to_deep_hash(params[:key]))
    Translate::Storage.new(@to_locale).write_to_file
    Translate::Log.new(@from_locale, @to_locale, params[:key].keys).write_to_file
    force_init_translations # Force reload from YAML file
    flash[:notice] = "Translations stored"
    redirect_to params.slice(:filter, :sort_by, :key_type, :key_pattern, :text_type, :text_pattern).merge({:action => :index})
  end

  def reload
    Translate::Keys.files = nil
    redirect_to :action => 'index'
  end
  
  private
  def initialize_keys
    @files = Translate::Keys.files
    @keys = (@files.keys.map(&:to_s) + Translate::Keys.new.i18n_keys(@from_locale)).uniq    
    @keys.reject! do |key|
      from_text = lookup(@from_locale, key)
      # When translating from one language to another, make sure there is a text to translate from.
      # Always exclude non string translation objects as we don't support editing them in the UI.
      (@from_locale != @to_locale && !from_text.present?) || (from_text.present? && !from_text.is_a?(String))      
    end
  end

  def lookup(locale, key)
    I18n.backend.send(:lookup, locale, key)
  end
  helper_method :lookup
  
  def filter_by_translated_or_changed
    params[:filter] ||= 'all'
    return if params[:filter] == 'all'
    @keys.reject! do |key|
      case params[:filter]
      when 'untranslated'
        lookup(@to_locale, key).present?
      when 'translated'
        lookup(@to_locale, key).blank?
      when 'changed'
        old_from_text(key).blank? || lookup(@from_locale, key) == old_from_text(key)
      else
        raise "Unknown filter '#{params[:filter]}'"
      end
    end
  end
  
  def filter_by_key_pattern
    return if params[:key_pattern].blank?
    @keys.reject! do |key|
      case params[:key_type]
      when "starts_with"
        !key.starts_with?(params[:key_pattern])
      when "contains"
        key.index(params[:key_pattern]).nil?
      else
        raise "Unknown key_type '#{params[:key_type]}'"
      end
    end
  end

  def filter_by_text_pattern
    return if params[:text_pattern].blank?
    @keys.reject! do |key|
      case params[:text_type]
      when 'contains'
        !lookup(@from_locale, key).present? || !lookup(@from_locale, key).to_s.downcase.index(params[:text_pattern].downcase)
      when 'equals'
        !lookup(@from_locale, key).present? || lookup(@from_locale, key).to_s.downcase != params[:text_pattern].downcase
      else
        raise "Unknown text_type '#{params[:text_type]}'"
      end
    end
  end

  def sort_keys
    params[:sort_by] ||= "key"
    case params[:sort_by]
    when "key"
      @keys.sort!
    when "text"
      @keys.sort! do |key1, key2|
        if lookup(@from_locale, key1).present? && lookup(@from_locale, key2).present?
          lookup(@from_locale, key1).to_s.downcase <=> lookup(@from_locale, key2).to_s.downcase
        elsif lookup(@from_locale, key1).present?
          -1
        else
          1
        end
      end
    else
      raise "Unknown sort_by '#{params[:sort_by]}'"
    end
  end
  
  def paginate_keys
    params[:page] ||= 1
    @paginated_keys = @keys[offset, per_page]
  end

  def offset
    (params[:page].to_i - 1) * per_page
  end
  
  def per_page
    50
  end
  helper_method :per_page
  
  def init_translations
    I18n.backend.send(:init_translations) unless I18n.backend.initialized?    
  end

  def force_init_translations
    I18n.backend.send(:init_translations)
  end
  
  def default_locale
    I18n.default_locale
  end
  
  def set_locale
    session[:from_locale] ||= default_locale
    session[:to_locale] ||= :en
    session[:from_locale] = params[:from_locale] if params[:from_locale].present?
    session[:to_locale] = params[:to_locale] if params[:to_locale].present?
    @from_locale = session[:from_locale].to_sym
    @to_locale = session[:to_locale].to_sym
  end
  
  def old_from_text(key)
    return @old_from_text[key] if @old_from_text && @old_from_text[key]
    @old_from_text = {}
    text = key.split(".").inject(log_hash) do |hash, k|
      hash ? hash[k] : nil
    end
    @old_from_text[key] = text
  end
  helper_method :old_from_text
  
  def log_hash
    @log_hash ||= Translate::Log.new(@from_locale, @to_locale, {}).read
  end
end
