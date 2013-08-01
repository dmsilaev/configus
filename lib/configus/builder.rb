class Configus::Builder
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
    if @envs_hash[@default_env] == {} && @default_env != :_inside
      raise ArgumentError,
        "Deafult evnironment #{ @default_env } is not defined!"
    end
  end

  def env(new_env, parent_hash = nil, &block)
    if parent_hash.nil?
      @envs_hash[new_env] = {}
    else
      parent = parent_hash[:parent]
      @envs_hash[new_env] = @envs_hash[parent].clone
    end
    @present_env = new_env
    instance_eval &block
  end

  def method_missing(method, *args, &block)
    node_key = method
    define_singleton_method(method) do |arg = nil, &method_block|
      if method_block
        this_node = @envs_hash[@present_env][node_key]
        new_node = self.class.new(:_inside, &method_block)
        if this_node
          this_hash = this_node.nested_hash
          new_hash = new_node.nested_hash
          this_hash.merge! new_hash
        else
          @envs_hash[@present_env][node_key] = new_node
        end
      elsif arg.nil?
        @envs_hash[@default_env][node_key]
      else
        @envs_hash[@present_env][node_key] = arg
      end
    end
    send method, *args, &block
  end

  def nested_hash
    @envs_hash[:_inside]
  end
end
