# frozen_string_literal: true

module ShardConnect
  module ConnectionHandlerSetCurrentShard
    def retrieve_connection(spec_name, role: ::ActiveRecord::Base.current_role, shard: ::ActiveRecord::Base.current_shard)
      conn = super
      conn.current_shard = shard
      conn.current_role = role
      conn
    end
  end

  module ConnectionHasCurrentShard
    attr_accessor :current_shard, :current_role
  end

  if ::ActiveRecord.gem_version >= Gem::Version.new('7.2.0')
    module ConnectionPoolSetCurrentShard
      def with_connection(prevent_permanent_checkout: false)
        lease = connection_lease
        if lease.connection
          lease.connection.current_shard = lease.connection.shard
          lease.connection.current_role = lease.connection.role
        end

        super
      end

      def active_connection?
        conn = connection_lease.connection
        if conn
          conn.current_shard = conn.shard
          conn.current_role = conn.role
        end
        conn
      end

      def active_connection
        conn = connection_lease.connection
        if conn
          conn.current_shard = conn.shard
          conn.current_role = conn.role
        end
        conn
      end

      def lease_connection
        lease = connection_lease
        lease.sticky = true
        lease.connection ||= checkout
        lease.connection.current_shard = lease.connection.shard
        lease.connection.current_role = lease.connection.role
        lease.connection
      end
    end

    ::ActiveRecord::ConnectionAdapters::ConnectionPool.prepend(ConnectionPoolSetCurrentShard)
  end

  ::ActiveRecord::ConnectionAdapters::ConnectionHandler.prepend(ConnectionHandlerSetCurrentShard)
  ::ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(ConnectionHasCurrentShard)
end
