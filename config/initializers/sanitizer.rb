# From Loofah 2.3.0, we should use Loofah::HTML5::SafeList over
# Loofah::HTML5::WhiteList
safe_list =
  if Loofah::HTML5.constants.include?(:SafeList)
    Loofah::HTML5::SafeList
  else
    Loofah::HTML5::WhiteList
  end

safe_list::ALLOWED_PROTOCOLS.merge(%w(message onenote obsidian))
