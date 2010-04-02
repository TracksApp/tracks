# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile
Mime::Type.register_alias "text/html", :m
Mime::Type.register_alias "text/plain", :autocomplete
