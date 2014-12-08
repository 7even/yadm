module YADM
  class CriteriaParser
    class ExpressionParser
      attr_reader :block
      
      def initialize(block)
        @block = block
      end
      
      def result
        instance_eval(&block).result
      end
      
      def method_missing(method_name, *args, &block)
        Attribute.new(method_name)
      end
      
      class << self
        def parse(block)
          new(block).result
        end
      end
      
      module Operand
        %i(== != < > <= >= + - * / & |).each do |symbol|
          define_method(symbol) do |arg|
            Expression.new(self, symbol, [arg])
          end
        end
      end
      
      class Expression
        include Operand
        
        attr_reader :receiver, :method_name, :arguments
        
        def initialize(receiver, method_name, arguments)
          @receiver    = receiver
          @method_name = method_name
          @arguments   = arguments
        end
        
        def result
          Criteria::Expression.new(
            receiver.result,
            method_name,
            arguments_result
          )
        end
        
        def arguments_result
          arguments.map do |argument|
            if argument.respond_to?(:result)
              argument.result
            else
              argument
            end
          end
        end
      end
      
      class Attribute
        include Operand
        
        attr_reader :name
        
        def initialize(name)
          @name = name
        end
        
        def result
          Criteria::Attribute.new(name)
        end
      end
    end
  end
end
