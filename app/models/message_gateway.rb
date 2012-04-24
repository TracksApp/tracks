class MessageGateway < ActionMailer::Base
  include ActionView::Helpers::SanitizeHelper
  extend ActionView::Helpers::SanitizeHelper::ClassMethods
  
  def receive(email)
    user = get_user_from_email_address(email)
    return if user.nil?
    
    context = user.prefs.sms_context
    description = nil
    notes = nil
    
    if email.multipart?
      description = get_text_or_nil(email.subject)
      notes = get_first_text_plain_part(email)
    else
      if email.subject.blank?
        description = get_decoded_text_or_nil(email.body)
        notes = nil
      else
        description = get_text_or_nil(email.subject)
        notes = get_decoded_text_or_nil(email.body)
      end
    end

    # stupid T-Mobile often sends the same message multiple times
    return if user.todos.where(:description => description).first

    todo = Todo.from_rich_message(user, context.id, description, notes)
    todo.save!
  end
  
  private
  
  def get_address(email)
    return SITE_CONFIG['email_dispatch'] == 'to' ?  email.to[0] :  email.from[0]
  end
  
  def get_user_from_email_address(email)
    address = get_address(email)
    user = User.where("preferences.sms_email" => address.strip).includes(:preference).first
    if user.nil?
      user = User.where("preferences.sms_email" => address.strip[1.100]).includes(:preference).first
    end
    return user
  end

  def get_text_or_nil(text)
    return text ? sanitize(text.strip) : nil
  end

  def get_decoded_text_or_nil(text)
    return text ? sanitize(text.decoded.strip) : nil
  end
  
  def get_first_text_plain_part(email)
    parts = email.parts.reject{|part| !part.content_type.start_with?("text/plain") }
    return parts ? sanitize(parts[0].decoded.strip) : ""
  end
  
end
