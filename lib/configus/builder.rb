module Configus
  class BuilderError < RuntimeError
  end

  class BuilderUndefinedEnvironmentError < BuilderError
  end

  class BuilderTwiceDefinedEnvironmentError < BuilderError
  end

  class BuilderTwiceDefinedKeyError < BuilderError
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
          get_new_nodes(node_key, method_block)
        elsif arg.nil?
          get_default_env_node(node_key)
        else
          set_present_env_node(node_key, arg)
        end
      end
      send method, *args, &block
    end

    protected
    def nested_hash
      @envs_hash[:_nested_env]
    end

    private
    def get_new_nodes(node_key, block)
      this_node = get_present_env_node(node_key)
      new_node = self.class.new(:_nested_env, &block)

      if this_node
        this_hash = this_node.nested_hash
        new_hash = new_node.nested_hash
        this_hash.merge! new_hash
      else
        set_present_env_node(node_key, new_node)
      end
    end

    def get_default_env_node(node_key)
      @envs_hash[@default_env][node_key]
    end

    def get_present_env_node(node_key)
      @envs_hash[@present_env][node_key]
    end

    def set_present_env_node(node_key, arg)
      @envs_hash[@present_env][node_key] = arg
    end
  end
end
