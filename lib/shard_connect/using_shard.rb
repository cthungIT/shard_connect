# frozen_string_literal: true
require 'shard_connect/relation_proxy'

class ShardConnect
  def self.hi
    puts 'Hello World!'
  end

  def self.using(role, shard = nil, &block)
    Rails.logger.info("#{self.class.name}:#{__method__}=>#{role}:#{shard}")
    current_role = ActiveRecord::Base.writing_role if role&.to_sym == :master
    current_role ||= ActiveRecord::Base.reading_role
    ActiveRecord::Base.connected_to(role: current_role, shard: shard&.to_sym, &block)
  end

  def self.current_role
    ActiveRecord::Base.current_role || ActiveRecord::Base.writing_role
  end

  module UsingShard
    def using(role, shard = nil)
      Rails.logger.info("#{self.class.name}:#{__method__}=>#{role}:#{shard}")
      ShardConnect::RelationProxy.new(all, role, shard&.to_sym)
    end
  end

  ::ActiveRecord::Base.singleton_class.prepend(UsingShard)
end
