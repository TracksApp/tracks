Dependencies.mechanism                             = :load
ActionController::Base.consider_all_requests_local = true
ActionController::Base.perform_caching             = false
BREAKPOINT_SERVER_PORT = 42531
# Use Memory Store if you are using FCGI, otherwise use file store
ActionController::Base.fragment_cache_store = ActionController::Caching::Fragments::MemoryStore.new
#ActionController::Base.fragment_cache_store = ActionController::Caching::Fragments::FileStore.new("/path/to/cache/directory")