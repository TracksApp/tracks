module PreferencesHelper

  def pref(model, pref_name, &block)
    s = "<label for #{model+pref_name}>#{Preference.human_attribute_name(pref_name)}:</label><br/>"
    s << yield
    s << "<br/><br/>"
    s
  end

  def pref_with_select_field(model, pref_name, collection = [ [t('preferences.is_true'),true], [t('preferences.is_false'), false] ])
    pref(model, pref_name) { select(model, pref_name, collection) }
  end

  def pref_with_text_field(model, pref_name, nowrap_label = false)
    pref(model, pref_name) { text_field(model, pref_name) }
  end

end
