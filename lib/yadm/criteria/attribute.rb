module YADM
  class Criteria
    class Attribute
      attr_reader :name
      
      def initialize(name)
        @name = name
      end
      
      def ==(other)
        other.respond_to?(:name) && name == other.name
      end
    end
  end
end
