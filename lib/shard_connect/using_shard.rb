# frozen_string_literal: true
class ShardConnect
  def self.hi
    puts 'Hello World!'
  end

  def self.using(role, shard = nil, &block)
    Rails.logger.info("ppp:#{self.class.name}:#{__method__}=>#{role}:#{shard}")
    specify_role = ::ActiveRecord::Base.writing_role if role&.to_sym == :master
    specify_role ||= ::ActiveRecord::Base.reading_role
    ::ActiveRecord::Base.connected_to(role: specify_role, shard: shard&.to_sym, &block)
  end

  module UsingShard
    def using(role, shard = nil)
      Rails.logger.info("000:#{self.class.name}:#{__method__}=>#{role}:#{shard}")
      ShardConnect::RelationProxy.new(all, role, shard&.to_sym)
    end
  end

  ::ActiveRecord::Base.singleton_class.prepend(UsingShard)
end
