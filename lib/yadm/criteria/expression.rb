module YADM
  class Criteria
    class Expression
      attr_reader :receiver, :method_name, :arguments
      
      def initialize(receiver, method_name, arguments)
        @receiver    = receiver
        @method_name = method_name
        @arguments   = arguments
      end
      
      class Attribute
        attr_reader :name
        
        def initialize(name)
          @name = name
        end
      end
    end
  end
end
