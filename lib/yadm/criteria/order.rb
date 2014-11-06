module YADM
  class Criteria
    class Order
      attr_reader :clauses
      
      def initialize(clauses)
        @clauses = clauses
      end
      
      class << self
        def merge(first_order, second_order)
          new(first_order.clauses + second_order.clauses)
        end
      end
      
      class Clause
        attr_reader :type, :expression
        
        def initialize(type, expression)
          @type       = type
          @expression = expression
        end
      end
    end
  end
end
