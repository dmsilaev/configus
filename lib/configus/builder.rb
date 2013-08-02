module Configus
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
        read_envs &block
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

        make_hash &block
      end

      def make_hash(&block)
        instance_eval &block
        # puts @envs_hash[@current_env]
      end

      def make_nested_hash(&block)
        instance_eval(&block)
        @nested_hash
      end

      def read_envs(&block)
        instance_eval &block
      end

      def method_missing(method, *args, &block)
        key = method
        if block_given?
          @nested_hash = {}
          @envs_hash[@current_env][key] = make_nested_hash(&block)
        else
          @nested_hash[key], _ = *args
          @envs_hash[@current_env][key], _ = *args
        end
      end

    end
  end
end
