class SMSGateway < ActionMailer::Base
  CONTEXT_NAME = 'Inbox'
  def receive(email)
    user = User.find(:first, :include => [:preference], :conditions => ["preferences.sms_email = ?", email.from[0].strip])
    context = user.prefs.sms_context

    description = nil
    notes = nil

    if email.content_type == "multipart/related"
      description = email.subject
      body_part = email.parts.find{|m| m.content_type == "text/plain"}
      notes = body_part.body.strip
    else
      if email.subject.empty?
        description = email.body.strip
        notes = nil
      else
        description = email.subject.strip
        notes = email.body.strip
      end
    end

    unless user.todos.find(:first, :conditions => {:description => description})
    # stupid T-Mobile often sends the same message multiple times
      todo = user.todos.create(:context => context, :description => description, :notes => notes)
    end
  end
end
