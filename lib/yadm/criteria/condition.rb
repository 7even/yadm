module YADM
  class Criteria
    class Condition
      attr_reader :expression
      
      def initialize(expression)
        @expression = expression
      end
      
      class << self
        def merge(first_condition, second_condition)
          expression = Expression.new(
            first_condition.expression,
            :&,
            [second_condition.expression]
          )
          
          new(expression)
        end
      end
    end
  end
end
