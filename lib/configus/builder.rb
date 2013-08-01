module Configus
  class BuilderError < RuntimeError
  end

  class BuilderUndefinedEnvironmentError < BuilderError
  end

  class BuilderTwiceDefinedEnvironmentError < BuilderError
  end

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
      instance_eval &block
      if @envs_hash[@default_env] == {} && @default_env != :_nested_env
        raise ArgumentError,
          "Deafult evnironment #{ @default_env } is not defined!"
      end
    end

    def env(new_env, param_hash = nil, &block)
      if @envs_hash[new_env] && new_env != @default_env
        raise BuilderTwiceDefinedEnvironmentError,
          "Enviroment #{ new_env } is defined twice!"
      end
      if param_hash.nil?
        @envs_hash[new_env] = {}
      else
        parent_key = param_hash[:parent]
        parent = @envs_hash[parent_key]
        if parent.nil? || parent == {}
          raise BuilderUndefinedEnvironmentError
        else
          @envs_hash[new_env] = parent.clone
        end
      end
      @present_env = new_env
      instance_eval &block
    end

    def method_missing(method, *args, &block)
      node_key = method
      define_singleton_method(method) do |arg = nil, &method_block|
        if method_block
          this_node = @envs_hash[@present_env][node_key]
          new_node = self.class.new(:_nested_env, &method_block)
          if this_node
            this_hash = this_node.nested_hash
            new_hash = new_node.nested_hash
            this_hash.merge! new_hash
          else
            @envs_hash[@present_env][node_key] = new_node
          end
        elsif arg.nil?
          @envs_hash[@default_env][node_key]
        else
          @envs_hash[@present_env][node_key] = arg
        end
      end
      send method, *args, &block
    end

    def nested_hash
      @envs_hash[:_nested_env]
    end
  end
end
