module YADM
  class Criteria
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
