module YADM
  class Criteria
    class Order
      attr_reader :type, :expression
      
      def initialize(type, expression)
        @type       = type
        @expression = expression
      end
    end
  end
end
