module YADM
  class Criteria
    class Limit
      attr_reader :limit
      
      def initialize(limit)
        @limit = limit
      end
    end
  end
end
