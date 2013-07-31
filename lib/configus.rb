require "configus/version"

module Configus

  class Builder

    attr_reader :all_env

    def initialize(default_env, &block)
      @all_env = {}
      @default_env = default_env
      instance_eval &block
    end
    
    def env(new_env)
      @all_env[new_env] = {} 
    end
  end
end
