Dependencies.mechanism                             = :load
ActionController::Base.consider_all_requests_local = true
ActionController::Base.perform_caching             = false
BREAKPOINT_SERVER_PORT = 42531
ActionController::Base.fragment_cache_store = ActionController::Caching::Fragments::MemoryStore.new