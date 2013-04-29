class MessageGateway < ActionMailer::Base
  include ActionView::Helpers::SanitizeHelper
  extend ActionView::Helpers::SanitizeHelper::ClassMethods
  
  def receive(email)
    user = get_user_from_email_address(email)
    return false if user.nil?
    
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

    todo = Todo.from_rich_message(user, context.id, description, notes)
    todo.save!
    Rails.logger.info "Saved email as todo for user #{user.login} in context #{context.name}"
  end
  
  private
  
  def get_address(email)
    return SITE_CONFIG['email_dispatch'] == 'to' ?  email.to[0] :  email.from[0]
  end
  
  def get_user_from_env_setting
    Rails.logger.info "All received email goes to #{ENV['TRACKS_MAIL_RECEIVER']}"
    user = User.find_by_login(ENV['TRACKS_MAIL_RECEIVER']).first
    Rails.logger.info "WARNING: Unknown user set for TRACKS_MAIL_RECEIVER (#{ENV['TRACKS_MAIL_RECEIVER']})" if user.nil?
    return user
  end
  
  def get_user_from_mail_header(email)
    address = get_address(email)
    Rails.logger.info "Looking for user with email #{address}"
    user = User.where("preferences.sms_email" => address.strip).includes(:preference).first
    if user.nil?
      user = User.where("preferences.sms_email" => address.strip[1.100]).includes(:preference).first
    end
    Rails.logger.info(!user.nil? ? "Email belongs to #{user.login}" : "User unknown")
    return user
  end
  
  def get_user_from_email_address(email)
    SITE_CONFIG['email_dispatch'] == 'single_user' ? get_user_from_env_setting : get_user_from_mail_header(email)
  end

  def get_text_or_nil(text)
    return text ? sanitize(text.strip) : nil
  end

  def get_decoded_text_or_nil(text)
    return text ? sanitize(text.decoded.strip) : nil
  end
  
  def get_first_text_plain_part(email)
    # get all parts from multipart/alternative attachments
    parts = get_all_parts(email.parts)
    
    # remove all parts that are not text/plain
    parts.reject{|part| !part.content_type.start_with?("text/plain") }
    
    return parts.count > 0 ? sanitize(parts[0].decoded.strip) : ""
  end
  
  def get_all_parts(parts)
    # return a flattened array of parts. If a multipart attachment is found, recurse over its parts
    all_parts = parts.inject([]) do |set, elem|
      if elem.content_type.start_with?("multipart/alternative")
        # recurse to handle multiparts in this multipart
        set += get_all_parts(elem.parts)
      else
        set << elem
      end
    end
  end
  
end
