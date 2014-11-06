module YADM
  class Criteria
    class Limit
      attr_reader :limit
      
      def initialize(limit)
        @limit = limit
      end
      
      class << self
        def merge(first_limit, second_limit)
          if first_limit && second_limit
            new(second_limit.limit) unless second_limit.limit.nil?
          else
            [first_limit, second_limit].compact.first
          end
        end
      end
    end
  end
end
