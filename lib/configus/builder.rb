module Configus
  class BuilderError < RuntimeError
  end

  class BuilderUndefinedEnvironmentError < BuilderError
  end

  class BuilderTwiceDefinedEnvironmentError < BuilderError
  end

  class BuilderTwiceDefinedKeyError < BuilderError
  end

  class BuilderNoKeyError < BuilderError
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
      @envs_hash[new_env] = {}
      if param_hash
        parent_key = param_hash[:parent]
        parent = @envs_hash[parent_key]
        if parent.nil? || parent == {}
          raise BuilderUndefinedEnvironmentError
        else
          @envs_hash[new_env][:_parent] = parent_key
        end
      end
      @present_env = new_env
      instance_eval &block
    end

    def method_missing(method, *args, &block)
      node_key = method
      define_singleton_method(method) do |arg = nil, &method_block|
        if method_block
          collect_new_nodes(node_key, method_block)
        elsif arg.nil?
          this_node = get_default_env_node(node_key)
          parent_node = get_default_parent_node(node_key)
          if this_node
            this_node
          elsif parent_node
            parent_node
          else
            raise BuilderNoKeyError, "No such key: '#{ node_key }'!"
          end
        else
          this_node = get_present_env_node(node_key)
          parent_node = get_parent_node(node_key)
          if this_node.nil?
            set_present_env_node(node_key, arg)
          elsif this_node == parent_node
            set_present_env_node(node_key, arg)
          else
            raise BuilderTwiceDefinedKeyError
          end
        end
      end
      send method, *args, &block
    end

    protected
    def nested_hash
      @envs_hash[:_nested_env]
    end

    private
    def collect_new_nodes(node_key, block)
      this_node = get_present_env_node(node_key)
      parent_node = get_parent_node(node_key)
      new_node = self.class.new(:_nested_env, &block)

      if parent_node.nil? && this_node.nil?
        set_present_env_node(node_key, new_node)
      elsif this_node.nil?
        this_node = parent_node.clone
        this_hash = this_node.nested_hash
        new_hash = new_node.nested_hash
        this_hash.merge! new_hash
      else
        raise BuilderTwiceDefinedKeyError
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

    def get_parent_node(node_key)
      parent_key = get_present_env_node(:_parent)
      if parent_key
        @envs_hash[parent_key][node_key]
      end
    end

    def get_default_parent_node(node_key)
      parent_key = get_default_env_node(:_parent)
      if parent_key
        @envs_hash[parent_key][node_key]
      end
    end
  end
end
