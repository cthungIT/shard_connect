# frozen_string_literal: true

# Implementation courtesy of db-charmer.
class ShardConnect
  module LogSubscriber
    attr_accessor :current_shard

    def sql(event)
      shard = event.payload[:connection]&.current_shard
      self.current_shard = shard == ActiveRecord::Base.default_shard ? nil : shard
      super
    end

    private

    def debug(progname = nil, &block)
      conn = if ActiveRecord.gem_version >= Gem::Version.new('7.1.0')
               if current_shard
                 color("[Shard: #{current_shard}]", ActiveSupport::LogSubscriber::GREEN,
                       bold: true)
               else
                 ''
               end
             else
               current_shard ? color("[Shard: #{current_shard}]", ActiveSupport::LogSubscriber::GREEN, true) : ''
             end
      super(conn + progname.to_s, &block)
    end
  end
end

ActiveRecord::LogSubscriber.prepend(Octoball::LogSubscriber)
