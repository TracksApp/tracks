module PreferencesHelper

  def pref(model, pref_name, &block)
    s = content_tag(:label, Preference.human_attribute_name(pref_name), :for => model+pref_name)
    s << "<br/>".html_safe
    s << yield
    s << "<br/><br/>".html_safe
    s
  end

  def pref_with_select_field(model, pref_name, collection = [ [t('preferences.is_true'),true], [t('preferences.is_false'), false] ])
    pref(model, pref_name) { select(model, pref_name, collection) }
  end

  def pref_with_text_field(model, pref_name)
    pref(model, pref_name) { text_field(model, pref_name) }
  end

end
