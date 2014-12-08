require 'yadm/criteria_parser/expression_parser'

module YADM
  class CriteriaParser
    attr_reader :block
    
    def initialize(block)
      @block = block
    end
    
    def result(arguments_group)
      arguments = block.arity.times.map do |index|
        YADM::Criteria::Argument.new(arguments_group, index)
      end
      
      instance_exec(*arguments, &block).result
    end
    
    %i(with ascending_by descending_by first).each do |method_name|
      define_method(method_name) do |*args, &block|
        Criteria.new.send(method_name, *args, &block)
      end
    end
    
    class << self
      def parse(block, arguments_group)
        new(block).result(arguments_group)
      end
    end
    
    class Criteria < YADM::Criteria
      def result
        YADM::Criteria.new(
          condition: condition,
          order:     order,
          limit:     limit
        )
      end
      
      def with(&block)
        expression = ExpressionParser.parse(block)
        merge Criteria.new(condition: Condition.new(expression))
      end
      
      def ascending_by(&block)
        expression = ExpressionParser.parse(block)
        clause = Order::Clause.new(:asc, expression)
        merge Criteria.new(order: Order.new([clause]))
      end
      
      def descending_by(&block)
        expression = ExpressionParser.parse(block)
        clause = Order::Clause.new(:desc, expression)
        merge Criteria.new(order: Order.new([clause]))
      end
      
      def first(limit)
        merge Criteria.new(limit: Limit.new(limit))
      end
    end
  end
end
