module Common
  def set_theme
    if prefs && prefs.theme
      @user_theme = prefs.theme.parameterize.underscore
    else
      @user_theme = SITE_CONFIG['default_theme'] || 'light_blue'
    end
  end
end
