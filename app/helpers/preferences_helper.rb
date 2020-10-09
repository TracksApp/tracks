module PreferencesHelper
  def pref(model, pref_name, &block)
    s = content_tag(:label, Preference.human_attribute_name(pref_name), :for => model + "_" + pref_name)
    s << yield
    s
  end

  def pref_with_check_box_field(model, pref_name)
    pref(model, pref_name) { check_box(model, pref_name, class: "form-control") }
  end

  def pref_with_select_field(model, pref_name, collection = [[t('preferences.is_true'), true], [t('preferences.is_false'), false]])
    pref(model, pref_name) { select(model, pref_name, collection, {}, class: "form-control") }
  end

  def pref_with_text_field(model, pref_name)
    pref(model, pref_name) { text_field(model, pref_name, class: "form-control") }
  end

  def profile_delete_user(user)
    return link_to(
      t('users.destroy_user'),
      url_for({ :controller => 'users', :action => 'destroy', :id => user.id }),
      { :id => "delete_user_#{user.id}",
        :class => "delete_user_button btn btn-danger",
        :title => t('users.destroy_user'),
        :x_confirm_message => t('users.destroy_confirmation', :login => user.login)
      })
  end
end
