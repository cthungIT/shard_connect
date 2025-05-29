# frozen_string_literal: true

class ShardConnect
  class RelationProxy < BasicObject
    attr_reader :current_shard, :current_role

    def initialize(rel, role, shard)
      @rel = rel
      Rails.logger.info("#{self.class.name}:#{role},#{shard}")
      self.current_role = ActiveRecord::Base.writing_role if role&.to_sym == :master
      self.current_role ||= ActiveRecord::Base.reading_role
      self.current_shard = shard
    end

    def current_role=(role)
      @current_role = role
      @rel.current_role = role unless @rel.is_a?(::Enumerator) # TODO: TESTING (current_role or specify_role)
    end

    def current_shard=(shard)
      @current_shard = shard
      @rel.current_shard = shard unless @rel.is_a?(::Enumerator) # TODO: TESTING (current_shard or specify_shard)
    end

    def using(role, shard = nil)
      self.current_role = role
      self.current_shard = shard
      self
    end

    def ar_relation
      @rel
    end

    def respond_to?(method, include_all = false)
      return true if %i[ar_relation current_role current_role= current_shard current_shard= using].include?(method)

      @rel.respond_to?(method, include_all)
    end

    ENUM_METHODS = (::Enumerable.instance_methods - ::Object.instance_methods).reject do |m|
      ::ActiveRecord::Relation.instance_method(m).source_location
    rescue StandardError
      nil
    end + %i[each map index_by]
    ENUM_WITH_BLOCK_METHODS = %i[find select none? any? one? many? sum].freeze

    def method_missing(method, *args, &block)
      return @rel.public_send(method, *args, &block) unless @rel.respond_to?(method)

      preamble = <<-EOS
          def #{method}(*margs, &mblock)
            return @rel.#{method}(*margs, &mblock) unless @current_role
      EOS
      postamble = <<-EOS
            return ret unless ret.is_a?(::ActiveRecord::Relation) || ret.is_a?(::ActiveRecord::QueryMethods::WhereChain) || ret.is_a?(::Enumerator)
            ::ShardConnect::RelationProxy.new(ret, @current_role, @current_shard)
          end
          ruby2_keywords(:#{method}) if respond_to?(:ruby2_keywords, true)
      EOS
      connected_to = '::ActiveRecord::Base.connected_to(role: @current_role, shard: @current_shard)'

      if ENUM_METHODS.include?(method)
        ::ShardConnect::RelationProxy.class_eval <<-EOS, __FILE__, __LINE__ - 1
            #{preamble}
            ret = #{connected_to} { @rel.to_a }.#{method}(*margs, &mblock)
            #{postamble}
        EOS
      elsif ENUM_WITH_BLOCK_METHODS.include?(method)
        ::ShardConnect::RelationProxy.class_eval <<-EOS, __FILE__, __LINE__ - 1
            #{preamble}
            ret = nil
            if mblock
              ret = #{connected_to} { @rel.to_a }.#{method}(*margs, &mblock)
            else
              #{connected_to} { ret = @rel.#{method}(*margs, &mblock); nil } # return nil to avoid loading relation
            end
            #{postamble}
        EOS
      else
        ::ShardConnect::RelationProxy.class_eval <<-EOS, __FILE__, __LINE__ - 1
            #{preamble}
            ret = nil
            #{connected_to} { ret = @rel.#{method}(*margs, &mblock); nil } # return nil to avoid loading relation
            #{postamble}
        EOS
      end

      public_send(method, *args, &block)
    end
    ruby2_keywords(:method_missing) if respond_to?(:ruby2_keywords, true)

    def inspect
      return @rel.inspect unless @current_role

      ::ActiveRecord::Base.connected_to(shard: @current_shard, role: @current_role) { @rel.inspect }
    end

    def ==(other)
      return false if other.respond_to?(:current_role) && other.current_role != @current_role
      return @rel == other unless @current_role

      ::ActiveRecord::Base.connected_to(shard: @current_shard, role: @current_role) { @rel == other }
    end

    def ===(obj)
      return false if obj.respond_to?(:current_shard) && obj.current_shard != @current_shard
      return @rel === obj unless @current_shard

      ::ActiveRecord::Base.connected_to(shard: @current_shard, role: @current_role) { @rel === obj }
    end
  end
end
