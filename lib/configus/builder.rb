module Configus
  class Builder
    class UndefinedEnvironmentError < RuntimeError; end
    class TwiceDefinedEnvironmentError < RuntimeError; end

    class << self
      def build(default_env, &block)
        @envs_hash = {}

        instance_eval &block

        if @envs_hash[default_env].nil?
          raise ArgumentError,
            "Deafult evnironment #{ default_env } is not defined!"
        end

        config = Configus::Config.new(@envs_hash[default_env])

        config
      end

      private
      def env(new_env, params = nil, &block)
        raise TwiceDefinedEnvironmentError if @envs_hash.key? new_env

        @envs_hash[new_env] = {}
        parent = params[:parent] if params

        if parent 
          raise UndefinedEnvironmentError unless @envs_hash.key? parent
          @envs_hash[new_env].deep_merge! @envs_hash[parent]
        end

        new_hash = Hasher.build &block
        @envs_hash[new_env].deep_merge! new_hash
      end
    end
  end
end
