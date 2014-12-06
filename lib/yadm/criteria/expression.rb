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
      
      class Attribute
        attr_reader :name
        
        def initialize(name)
          @name = name
        end
        
        def ==(other)
          other.respond_to?(:name) && name == other.name
        end
      end
      
      class Argument
        attr_reader :group, :index
        
        def initialize(group, index)
          @group = group
          @index = index
        end
        
        def ==(other)
          %i(group index).all? do |method|
            other.respond_to?(method) && send(method) == other.send(method)
          end
        end
        
        def fetch_from(values)
          values[group][index]
        end
      end
    end
  end
end
