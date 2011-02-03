module UsersHelper
  def remote_delete_user(user)
    return link_to(
      image_tag("blank.png", :title =>t('users.destroy_user'), :class=>"delete_item"),
      url_for({:controller => 'users', :action => 'destroy', :id => user.id}),
      {:id => "delete_user_#{user.id}",
        :class => "delete_user_button",
        :title => t('users.destroy_user'),
        :x_confirm_message => t('users.destroy_confirmation', :login => user.login)
      })
  end
end
