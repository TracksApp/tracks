Gem::Specification.new do |s|
  s.name    = 'cache_digests'
  s.version = '0.1.0'
  s.author  = 'David Heinemeier Hansson'
  s.email   = 'david@37signals.com'
  s.summary = 'Nested fragment caches with (even) less situps'

  s.required_ruby_version = '>= 1.8.7'

  s.add_dependency 'actionpack', '>= 3.2'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'

  s.files = Dir["#{File.dirname(__FILE__)}/**/*"]
end
