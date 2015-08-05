class MessageGateway < ActionMailer::Base

  def receive(email)
    user = get_receiving_user_from_email_address(email)
    return false if user.nil?
    return false unless check_sender_is_in_mailmap(user, email)

    context = user.prefs.sms_context
    todo_params = get_todo_params(email)

    todo_builder = TodoFromRichMessage.new(user, context.id, todo_params[:description], todo_params[:notes])
    todo = todo_builder.construct

    if todo.save!
      Rails.logger.info "Saved email as todo for user #{user.login} in context #{context.name}"

      if attach_email_to_todo(todo, email)
        Rails.logger.info "Saved email as attachment to todo for user #{user.login} in context #{context.name}"
      end
    end
    todo
  end

  private

  def attach_email_to_todo(todo, email)
    attachment = todo.attachments.build

    # create temp file
    tmp = Tempfile.new(['attachment', '.eml'], {universal_newline: true})
    tmp.write email.raw_source.gsub(/\r/, "")

    # add temp file to attachment. paperclip will copy the file to the right location
    Rails.logger.info "Saved received email to #{tmp.path}"
    attachment.file = tmp
    tmp.close
    saved = attachment.save!

    # enable write permissions on group, since MessageGateway could be run under different
    # user than Tracks (i.e. apache versus mail)
    dir = File.open(File.dirname(attachment.file.path))
    dir.chmod(0770)

    # delete temp file
    tmp.unlink
  end

  def get_todo_params(email)
    params = {}

    if email.multipart?
      params[:description] = get_text_or_nil(email.subject)
      params[:notes]       = get_first_text_plain_part(email)
    else
      if email.subject.blank?
        params[:description] = get_decoded_text_or_nil(email.body)
        params[:notes]       = nil
      else
        params[:description] = get_text_or_nil(email.subject)
        params[:notes]       = get_decoded_text_or_nil(email.body)
      end
    end
    params
  end

  def get_receiving_user_from_email_address(email)
    SITE_CONFIG['email_dispatch'] == 'single_user' ? get_receiving_user_from_env_setting : get_receiving_user_from_mail_header(email)
  end

  def get_receiving_user_from_env_setting
    Rails.logger.info "All received email goes to #{ENV['TRACKS_MAIL_RECEIVER']}"
    user = User.where(:login => ENV['TRACKS_MAIL_RECEIVER']).first
    Rails.logger.info "WARNING: Unknown user set for TRACKS_MAIL_RECEIVER (#{ENV['TRACKS_MAIL_RECEIVER']})" if user.nil?
    return user
  end

  def get_receiving_user_from_mail_header(email)
    user = get_receiving_user_from_sms_email( get_address(email) )
    Rails.logger.info(user.nil? ? "User unknown": "Email belongs to #{user.login}")
    return user
  end

  def get_address(email)
    return SITE_CONFIG['email_dispatch'] == 'to' ?  email.to[0] :  email.from[0]
  end

  def get_receiving_user_from_sms_email(address)
    Rails.logger.info "Looking for user with email #{address}"
    user = User.where("preferences.sms_email" => address.strip).includes(:preference).first
    user = User.where("preferences.sms_email" => address.strip[1.100]).includes(:preference).first if user.nil?
    return user
  end

  def check_sender_is_in_mailmap(user, email)
    if user.present? and !sender_is_in_mailmap?(user,email)
      Rails.logger.warn "#{email.from[0]} not found in mailmap for #{user.login}"
      return false
    end
    return true
  end

  def sender_is_in_mailmap?(user,email)
    if SITE_CONFIG['mailmap'].is_a? Hash and SITE_CONFIG['email_dispatch'] == 'to'
      # Look for the sender in the map of allowed senders
      SITE_CONFIG['mailmap'][user.preference.sms_email].include? email.from[0]
    else
      # We can't check the map if it's not defined, or if the lookup is the
      # wrong way round, so just allow it
      true
    end
  end

  def get_text_or_nil(text)
    return text ? text.strip : nil
  end

  def get_decoded_text_or_nil(text)
    return text ? text.decoded.strip : nil
  end

  def get_first_text_plain_part(email)
    # get all parts from multipart/alternative attachments
    parts = get_all_parts(email.parts)

    # remove all parts that are not text/plain
    parts.reject{|part| !part.content_type.start_with?("text/plain") }

    return parts.count > 0 ? parts[0].decoded.strip : ""
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
