module YADM
  class Criteria
    class Limit
      attr_reader :limit
      
      def initialize(limit)
        @limit = limit
      end
      
      class << self
        def merge(first_limit, second_limit)
          new(second_limit.limit)
        end
      end
    end
  end
end
