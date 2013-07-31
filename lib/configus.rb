require "configus/version"

module Configus
  class Builder

    attr_reader :all_env, :default_env

    class << self
      alias :build :new
    end

    def initialize(default_env, &block)
      @all_env = {}
      @present_env = default_env
      @default_env = default_env
      instance_eval &block
    end
    
    def env(new_env, &block)
      @all_env[new_env] = {}
      @present_env = new_env
      instance_eval &block
    end

    def method_missing(method, *args, &block)
      # TODO: add super.
      define_singleton_method(method) do |arg = nil|
        if arg.nil?
          @all_env[@default_env][method]
        else
          @all_env[@present_env] = { method => arg }
        end
      end
      send method, *args
    end
  end
end
