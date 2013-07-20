# Have Mini Profiler show up on the right
Rack::MiniProfiler.config.position = 'right'

# Have Mini Profiler start in hidden mode - display with short cut (defaulted to 'Alt+P')
Rack::MiniProfiler.config.start_hidden = true

# Don't collect backtraces on SQL queries that take less than 5 ms to execute
# (necessary on Rubies earlier than 2.0)
# Rack::MiniProfiler.config.backtrace_threshold_ms = 5

# Use memory storage
Rack::MiniProfiler.config.storage = Rack::MiniProfiler::MemoryStore