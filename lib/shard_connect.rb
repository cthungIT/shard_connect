# frozen_string_literal: true

require 'active_record'
require 'shard_connect/version'

require 'shard_connect/relation_proxy'
require 'shard_connect/connection_adapters'
require 'shard_connect/using_shard'

# ActiveSupport.on_load(:active_record) do
#   require 'shard_connect/relation_proxy'
#   require 'shard_connect/connection_adapters'
#   # require 'shard_connect/connection_handling'
#   #   require 'shard_connect/current_shard_tracker'
#   #   require 'shard_connect/association_shard_check'
#   # require 'shard_connect/shared_persistence'
#   #   require 'shard_connect/association'
#   #   require 'shard_connect/log_subscriber'
#   require 'shard_connect/using_shard'
# end
