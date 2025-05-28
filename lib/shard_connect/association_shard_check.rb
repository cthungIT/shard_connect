# frozen_string_literal: true

class ShardConnect
  class MismatchedShards < StandardError
    attr_reader :record, :current_shard, :current_role

    def initialize(record, current_role, current_shard)
      @record = record
      @current_role = current_role
      @current_shard = current_shard
    end

    def message
      "Association shard mismatch: record shard is \"#{record.current_shard}\" but current shard is \"#{current_shard}\""
    end
  end

  module AssociationShardCheck
    def association_shard_check(record)
      raise MismatchedShards.new(record, current_role, current_shard) if record.current_shard != current_shard
    end
  end

  module AssociationShardChecker
    def has_many(name, scope = nil, **options, &extension)
      assign_shard_check_opts(options)
      super
    end

    def has_and_belongs_to_many(association_id, scope = nil, **options, &extension)
      assign_shard_check_opts(options)
      super
    end

    private

    def assign_shard_check_opts(options)
      options[:before_add] = [:association_shard_check, options[:before_add]].compact.flatten
      options[:before_remove] = [:association_shard_check, options[:before_remove]].compact.flatten
    end
  end

  ::ActiveRecord::Base.prepend(AssociationShardCheck)
  ::ActiveRecord::Base.singleton_class.prepend(AssociationShardChecker)
end
