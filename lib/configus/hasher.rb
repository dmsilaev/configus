module Configus
  class Hasher
    attr_reader :hash

    class TwiceDefinedKeyError < RuntimeError; end

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
      raise TwiceDefinedKeyError unless @hash[method].nil?
      if block_given?
        @hash[method] = Hasher.build &block
      else
        @hash[method], _ = * args
      end
    end
  end
end
