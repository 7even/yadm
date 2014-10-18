module YADM
  class Mapping
    class Attribute
      COERCIONS = {
        Integer => -> (value) { value.to_i },
        String  => -> (value) { value.to_s }
      }.tap do |hash|
        hash.default = -> (value) { value }
      end
      
      attr_reader :type
      protected :type
      
      def initialize(type)
        @type = type
      end
      
      def ==(other)
        type == other.type
      end
      
      def coerce(value)
        if value.nil?
          nil
        else
          COERCIONS[type].call(value)
        end
      end
    end
  end
end
