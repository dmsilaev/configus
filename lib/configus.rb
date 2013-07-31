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
      if block.nil?
        define_singleton_method(method) do |arg = nil|
          if arg.nil?
            @envs_hash[@default_env][method]
          else
            @envs_hash[@present_env][method] = arg
          end
        end
        send method, *args
      else
        @envs_hash[@present_env][method] = self.class.new(:_inside, &block)
        define_singleton_method(method) do
          @envs_hash[@default_env][method]
        end
      end
    end
  end
end
