module YADM
  module Adapters
    class << self
      def fetch(name)
        registry.fetch(name)
      rescue KeyError
        raise NotImplementedError, "Adapter `#{name.inspect}` isn't registered."
      end
      
      def register(name, adapter)
        registry[name] = adapter
      end
      
    private
      def registry
        @registry ||= {}
      end
    end
    
    module Base
      def self.included(including_module)
        including_module.extend ClassMethods
      end
      
      module ClassMethods
        def register(name)
          Adapters.register(name, self)
        end
      end
    end
  end
end
