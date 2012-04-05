# Get long stack traces for easier debugging; you'll thank me later.
Rails.backtrace_cleaner.remove_silencers! if Rails.respond_to?(:backtrace_cleaner)
