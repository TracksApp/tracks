module PreferencesHelper

  def pref(model, pref_name, &block)
    s = content_tag(:label, Preference.human_attribute_name(pref_name), :for => model+pref_name)
    s << yield
    s
  end

  def pref_with_select_field(model, pref_name, collection = [ [t('preferences.is_true'),true], [t('preferences.is_false'), false] ])
    pref(model, pref_name) { select(model, pref_name, collection, {}, class: "form-control") }
  end

  def pref_with_text_field(model, pref_name)
    pref(model, pref_name) { text_field(model, pref_name, class: "form-control") }
  end

end
