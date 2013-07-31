require "configus/version"

module Configus
  class Builder

    attr_reader :envs_hash, :default_env

    class << self
      alias :build :new
    end

    def initialize(default_env, &block)
      @envs_hash = {}
      @present_env = default_env
      @envs_hash[@present_env] = {}
      @default_env = default_env
      @put_to = nil
      instance_eval &block
    end
    
    def env(new_env, parent_hash = nil, &block)
      if parent_hash.nil?
        @envs_hash[new_env] = {}
      else
        parent = parent_hash[:parent]
        @envs_hash[new_env] = @envs_hash[parent].dup
      end
      @present_env = new_env
      instance_eval &block
    end

    def method_missing(method, *args, &block)
      define_singleton_method(method) do |arg = nil, &method_block|
        if method_block
          nested_object = @envs_hash[@present_env][method]
          new_hash_carrier = self.class.new(:_inside, &method_block)
          if nested_object
            nested_object_hash = nested_object.envs_hash[:_inside]
            nested_object_hash.merge! new_hash_carrier.envs_hash[:_inside]
          else
            @envs_hash[@present_env][method] = new_hash_carrier
          end
        elsif arg.nil?
          @envs_hash[@default_env][method]
        else
          @envs_hash[@present_env][method] = arg
        end
      end
      send method, *args, &block
    end
  end
end
