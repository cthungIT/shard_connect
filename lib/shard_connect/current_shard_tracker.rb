# frozen_string_literal: true

module ShardConnect
  module CurrentShardTracker
    attr_reader :specify_shard, :specify_role

    def becomes(klass)
      became = super
      became.instance_variable_set(:@specify_shard, current_shard)
      became.instance_variable_set(:@specify_role, current_role)
      became
    end

    def ==(other)
      super && current_shard == other.current_shard
    end

    module ClassMethods
      private

      def instantiate_instance_of(klass, attributes, column_types = {}, &block)
        result = super
        result.instance_variable_set(:@specify_shard, current_shard)
        result.instance_variable_set(:@specify_role, current_role)
        result
      end
    end
  end

  ::ActiveRecord::Base.prepend(CurrentShardTracker)
  ::ActiveRecord::Base.singleton_class.prepend(CurrentShardTracker::ClassMethods)
end
