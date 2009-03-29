class MessageGateway < ActionMailer::Base
  include ActionView::Helpers::SanitizeHelper
  extend ActionView::Helpers::SanitizeHelper::ClassMethods
  
  def receive(email)
    address = ''
    if SITE_CONFIG['email_dispatch'] == 'to'
      address = email.to[0]
    else
      address = email.from[0]
    end
    
    user = User.find(:first, :include => [:preference], :conditions => ["preferences.sms_email = ?", address.strip])
    if user.nil?
      user = User.find(:first, :include => [:preference], :conditions => ["preferences.sms_email = ?", address.strip[1,100]])
    end
    return if user.nil?
    context = user.prefs.sms_context

    description = nil
    notes = nil

    if email.content_type == "multipart/related"
      description = sanitize email.subject
      body_part = email.parts.find{|m| m.content_type == "text/plain"}
      notes = sanitize body_part.body.strip
    else
      if email.subject.empty?
        description = sanitize email.body.strip
        notes = nil
      else
        description = sanitize email.subject.strip
        notes = sanitize email.body.strip
      end
    end

    # stupid T-Mobile often sends the same message multiple times
    return if user.todos.find(:first, :conditions => {:description => description})

    todo = Todo.from_rich_message(user, context.id, description, notes)
    todo.save!
  end
end
