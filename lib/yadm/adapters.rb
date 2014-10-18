module YADM
  module Adapters
    class << self
      def fetch(name)
        const_get(class_name_for(name))
      rescue NameError
        raise NotImplementedError, "Adapter `#{name.inspect}` isn't registered."
      end
      
    private
      def class_name_for(name)
        name.to_s.split('_').map(&:capitalize).join + 'Adapter'
      end
    end
  end
end
