# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'shard_connect/version'

Gem::Specification.new do |s|
  s.name        = 'ar-shard'
  s.version     = ShardConnect::VERSION
  s.licenses    = ['MIT']
  s.summary     = 'ShardConnect-like Database Sharding Helper for ActiveRecord 6.1+'
  s.description = "ShardConnect provides Octopus-like database sharding helper methods for ActiveRecord 6.1 or later, using Rails' native horizontal sharding handling. This provides migration path to Rails 6.1+ for applications using Octopus gem with older Rails."
  s.authors     = ['Johny Cao']
  s.email       = 'cthung.it2013@gmail.com'
  s.files       = `git ls-files lib`.split("\n")
  # s.files = ['lib/shard_connect.rb', 'lib/shard_connect/version.rb', 'lib/shard_connect/using_shard.rb', 'lib/shard_connect/relation_proxy.rb']
  # s.test_files  = `git ls-files -- {spec}/*`.split("\n")
  s.homepage    = 'https://github.com/cthungIT/shard_connect'
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.6.10'
end
