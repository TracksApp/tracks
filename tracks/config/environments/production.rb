Dependencies.mechanism                             = :require
ActionController::Base.consider_all_requests_local = false
ActionController::Base.perform_caching             = true
ActionController::Base.fragment_cache_store = ActionController::Caching::Fragments::MemoryStore.new