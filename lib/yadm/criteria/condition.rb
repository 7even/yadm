module YADM
  class Criteria
    class Condition
      attr_reader :expression
      
      def initialize(expression)
        @expression = expression
      end
      
      def ==(other)
        other.respond_to?(:expression) && expression == other.expression
      end
      
      class << self
        def merge(first_condition, second_condition)
          if first_condition && second_condition
            expression = Expression.new(
              first_condition.expression,
              :&,
              [second_condition.expression]
            )
            
            new(expression)
          else
            [first_condition, second_condition].compact.first
          end
        end
      end
    end
  end
end
