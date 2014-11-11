module YADM
  class Query
    attr_reader :criteria, :arguments
    
    def initialize(criteria = Criteria.new, arguments = [])
      @criteria  = criteria
      @arguments = arguments
    end
    
    def merge(new_criteria, new_arguments)
      self.class.new(criteria.merge(new_criteria), arguments + new_arguments)
    end
  end
end
