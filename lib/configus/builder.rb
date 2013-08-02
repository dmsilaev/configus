module Configus
  class Hasher
    attr_reader :hash
    class << self
      def build(&block)
        hasher = new &block

        hasher.hash
      end
    end

    def initialize(&block)
      @hash = {}

      instance_eval &block
    end

    def method_missing(method, *args, &block)
      if block_given?
        @hash[method] = Hasher.build &block
      else
        @hash[method], _ = * args
      end
    end
  end

  class Builder
    # attr_reader :envs_hash, :default_env

    class << self
      def build(default_env, &block)
        @envs_hash = {}
        @current_env = nil
        @current_parent = nil
        @default_env = default_env
        instance_eval &block
        #puts @envs_hash
        config = Configus::Config.new(@envs_hash[@default_env])

        config
      end

      def env(new_env, params = nil, &block)
        @current_env = new_env
        @envs_hash[@current_env] = {}
        parent = params[:parent] if params
        if parent 
          deep_merge! @envs_hash[@current_env], @envs_hash[parent]
        end

        instance_eval &block
      end

      def method_missing(method, *args, &block)
        key = method
        current_hash = @envs_hash[@current_env]
        if block_given?
          if current_hash[key].nil?
            current_hash[key] = {}
          end
          new_hash = Hasher.build &block
          deep_merge!(current_hash[key], new_hash)
        else
          current_hash[key], _ = *args
        end
      end

      def deep_merge!(hash1, hash2)
        hash1.merge!(hash2) do |key, oldval, newval|
          if (oldval.is_a? Hash) && (newval.is_a? Hash)
            deep_merge!(oldval, newval)
          else
            newval
          end
        end
      end
    end
  end
end
