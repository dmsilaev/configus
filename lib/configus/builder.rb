module Configus
  class Hasher
    class << self
      attr_reader :hash

      def build(&block)
        @hash = {}
        instance_eval &block

        @hash
      end

      def method_missing(method, *args, &block)
        key = method
        if block_given?
          @hash[key] = Hasher.build &block
        else
          @hash[key], _ = * args
        end
      end
    end
  end
  class Builder
    # attr_reader :envs_hash, :default_env

    class << self
      attr_reader :default_env, :hash

      def build(default_env, &block)
        @hash = {}
        @envs_hash = {}
        @nested_hash = {}
        @current_env = nil
        @default_env = default_env
        instance_eval &block
        puts @envs_hash[@default_env]
        config = Configus::Config.new(@envs_hash[@default_env])

        config
      end

      def env(new_env, params = nil, &block)
        @current_env = new_env
        @envs_hash[@current_env] = {}
        parent = params[:parent] if params
        if parent 
          @envs_hash[@current_env].merge! @envs_hash[parent]
        end

        instance_eval &block
      end

      def method_missing(method, *args, &block)
        key = method
        current_hash = @envs_hash[@current_env]
        if block_given?
          current_hash[key] = Hasher.build &block
        else
          current_hash[key], _ = *args
        end
      end
    end
  end
end
