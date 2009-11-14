# See test_url_with_slash_in_query_string_are_parsed_correctly in test/functional/todos_controller_test.rb
# and http://blog.swivel.com/code/2009/06/rails-auto_link-and-certain-query-strings.html
module ActionView::Helpers::TextHelper
  remove_const :AUTO_LINK_RE
  AUTO_LINK_RE = %r{
              (                          # leading text
                <\w+.*?>|                # leading HTML tag, or
                [^=!:'"/]|               # leading punctuation, or
                ^                        # beginning of line
              )
              (
                (?:https?://)|           # protocol spec, or
                (?:www\.)                # www.*
              )
              (
                [-\w]+                   # subdomain or domain
                (?:\.[-\w]+)*            # remaining subdomains or domain
                (?::\d+)?                # port
                (?:/(?:[~\w\+@%=\(\)-]|(?:[,.;:'][^\s$]))*)* # path
                (?:\?[\w\+@%&=.;:/-]+)?     # query string
                (?:\#[\w\-]*)?           # trailing anchor
              )
              ([[:punct:]]|<|$|)       # trailing text
             }x
end
