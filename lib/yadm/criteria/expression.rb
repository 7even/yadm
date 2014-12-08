module YADM
  class Criteria
    class Expression
      attr_reader :receiver, :method_name, :arguments
      
      def initialize(receiver, method_name, arguments)
        @receiver    = receiver
        @method_name = method_name
        @arguments   = arguments
      end
      
      def ==(other)
        %i(receiver method_name arguments).all? do |method|
          other.respond_to?(method) && send(method) == other.send(method)
        end
      end
    end
  end
end
