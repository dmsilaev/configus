module Configus
  class Builder
    class UndefinedEnvironmentError < RuntimeError; end
    class TwiceDefinedEnvironmentError < RuntimeError; end

    class << self
      def build(default_env, &block)
        @envs_hash = {}
        @current_env = nil
        @default_env = default_env

        instance_eval &block

        if @envs_hash[@default_env].nil?
          raise ArgumentError,
            "Deafult evnironment #{ @default_env } is not defined!"
        end

        config = Configus::Config.new(@envs_hash[@default_env])

        config
      end

      private
      def env(new_env, params = nil, &block)
        raise TwiceDefinedEnvironmentError if @envs_hash.key? new_env

        @current_env = new_env
        @envs_hash[@current_env] = {}
        parent = params[:parent] if params

        if parent 
          raise UndefinedEnvironmentError unless @envs_hash.key? parent
          deep_merge! @envs_hash[@current_env], @envs_hash[parent]
        end

        new_hash = Hasher.build &block
        deep_merge!(@envs_hash[@current_env], new_hash)
      end

      def deep_merge!(dest, source)
        dest.merge!(source) do |key, dest_val, source_val|
          if dest_val.is_a? Hash
            deep_merge!(dest_val, source_val)
          else
            source_val
          end
        end
      end
    end
  end
end
