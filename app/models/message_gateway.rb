class MessageGateway < ActionMailer::Base
  def receive(email)
    user = User.find(:first, :include => [:preference], :conditions => ["preferences.sms_email = ?", email.from[0].strip])
    if user.nil?
      user = User.find(:first, :include => [:preference], :conditions => ["preferences.sms_email = ?", email.from[0].strip[1,100]])
    end
    return if user.nil?
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

    # stupid T-Mobile often sends the same message multiple times
    return if user.todos.find(:first, :conditions => {:description => description})

    # parse context
    context_data = description.match(/^([^ ]*): (.*)/)
    if context_data
      context_name = context_data[1]
      custom_context = user.contexts.find(:first, :conditions => {:name => context_name})
      if custom_context
        context = custom_context
        description = context_data[2]
      end
    end

    # parse due date
    due_regex = / ?due:([0-9\/-]{3,})/
    due_date = description.match(due_regex)[1] rescue nil
    if due_date
      #strip from description
      description.sub!(due_regex, '').strip!
    end

    # parse due date
    show_regex = / ?show:([0-9\/-]{3,})/
    show_date = description.match(show_regex)[1] rescue nil
    if show_date
      #strip from description
      description.sub!(show_regex, '').strip!
    end

    # p "creating todo with description '#{description}', show from #{show_date}, context #{context.name}"
    todo = user.todos.create(:context => context, :description => description, :notes => notes, :due => due_date, :show_from => show_date)
    # p todo.validate
  end
end
