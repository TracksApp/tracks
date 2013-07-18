class RichMessageExtractor

  RICH_MESSAGE_FIELDS_REGEX = /([^>@]*)@?([^>]*)>?(.*)/

  def initialize(message)
    @message = message
  end

  def description
    fields[1].strip
  end

  def context
    fields[2].strip
  end

  def project
    stripped = fields[3].strip
    stripped.blank? ? nil : stripped
  end

  private

    def fields
      @message.match(RICH_MESSAGE_FIELDS_REGEX)
    end

end
