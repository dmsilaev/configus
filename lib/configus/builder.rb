module Configus
    class Builder

    class << self
      def build(default_env, &block)
        @envs_hash = {}
        @current_env = nil
        @default_env = default_env
        instance_eval &block
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
          current_hash[key] = {} if current_hash[key].nil?
          new_hash = Hasher.build &block
          deep_merge!(current_hash[key], new_hash)
        else
          current_hash[key], _ = *args
        end
      end

      def deep_merge!(hash1, hash2)
        hash1.merge!(hash2) do |key, oldval, newval|
          if oldval.is_a? Hash
            deep_merge!(oldval, newval)
          else
            newval
          end
        end
      end
    end
  end
end
