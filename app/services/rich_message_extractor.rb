require 'date'
class RichMessageExtractor
  include ActionView::Helpers::SanitizeHelper
  extend ActionView::Helpers::SanitizeHelper::ClassMethods

  PROJECT_MARKER = '~'
  CONTEXT_MARKER = '@'
  TICKLER_MARKER = '>'
  DUE_MARKER = '<'
  TAG_MARKER = '#'
  STAR_MARKER = '*'

  ALL_MARKERS = [
    PROJECT_MARKER,
    CONTEXT_MARKER,
    TICKLER_MARKER,
    DUE_MARKER,
    TAG_MARKER,
    STAR_MARKER
  ]

  def initialize(message)
    @message = message
  end

  def description
    desc = select_for('')
    desc.blank? ? '' : sanitize(desc[1].strip)
  end

  def context
    context = select_for(CONTEXT_MARKER)
    context.blank? ? '' : sanitize(context[1].strip)
  end

  def project
    project = select_for PROJECT_MARKER
    project.blank? ? nil : sanitize(project[1].strip)
  end

  def tags
    string = @message.dup
    tags = []
    # Regex only matches one tag, so recurse until we have them all
    while string.match /#(.*?)(?=[#{ALL_MARKERS.join}]|\Z)/
      tags << sanitize($1)
      string.gsub!(/##{$1}/,'')
    end
    tags.empty? ? nil : tags
  end

  def due
    due = select_for DUE_MARKER
    due.blank? ? nil : Time.zone.parse(fix_date_string(due[1].strip))
  end

  def show_from
    show_from = select_for TICKLER_MARKER
    show_from.blank? ? nil : Time.zone.parse(fix_date_string(show_from[1].strip))
  end

  def starred?
    @message.include? '*'
  end

  private

  def select_for symbol
    @message.match /#{symbol}(.*?)(?=[#{ALL_MARKERS.join}]|\Z)/
  end

  def fix_date_string yymmdd
    "20#{yymmdd[0..1]}-#{yymmdd[2..3]}-#{yymmdd[4..5]} 00:00"
  end

end
