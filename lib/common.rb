module Common
  def set_theme
    if prefs && prefs.theme
      @user_theme = prefs.theme.parameterize.underscore
    else
      @user_theme = SITE_CONFIG['default_theme'] || 'light_blue'
    end
  end

  def self.like_operator
    # HACK: This is something of a hack to use the correct operator for Pg
    if ActiveRecord::Base.connection.adapter_name.downcase.to_sym == :postgresql
      like = 'ILIKE'
    else
      like = 'LIKE'
    end
    return like
  end
end
