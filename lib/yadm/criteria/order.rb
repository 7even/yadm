module YADM
  class Criteria
    class Order
      attr_reader :clauses
      
      def initialize(clauses)
        @clauses = clauses
      end
      
      def ==(other)
        other.respond_to?(:clauses) && clauses == other.clauses
      end
      
      class << self
        def merge(first_order, second_order)
          if first_order && second_order
            new(first_order.clauses + second_order.clauses)
          else
            [first_order, second_order].compact.first
          end
        end
      end
      
      class Clause
        attr_reader :type, :expression
        
        def initialize(type, expression)
          @type = type.to_sym
          @expression = expression
        end
        
        def asc?
          type == :asc
        end
        
        def desc?
          type == :desc
        end
        
        def ==(other)
          %i(type expression).all? do |method|
            other.respond_to?(method) && send(method) == other.send(method)
          end
        end
      end
    end
  end
end
