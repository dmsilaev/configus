module Configus
  class Config
    def initialize(hash)
      hash.each_pair do |key, value|
        create_method(key, value)
      end
    end

    def create_method(method, body)
      define_singleton_method(method) do 
        if body.is_a? Hash
          self.class.new(body)
        else
          body
        end
      end
    end
  end
end