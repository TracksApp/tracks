Dependencies.mechanism                             = :require
ActionController::Base.consider_all_requests_local = false
ActionController::Base.perform_caching             = true
# Use Memory Store if you are using FCGI, otherwise use file store
ActionController::Base.fragment_cache_store = ActionController::Caching::Fragments::MemoryStore.new
#ActionController::Base.fragment_cache_store = ActionController::Caching::Fragments::FileStore.new("/path/to/cache/directory")
