module YADM
  class Query
    attr_reader :criteria, :arguments
    
    include Enumerable
    
    def initialize(criteria = Criteria.new, arguments = {})
      @criteria  = criteria
      @arguments = arguments
    end
    
    def merge(new_criteria, new_arguments)
      self.class.new(criteria.merge(new_criteria), arguments.merge(new_arguments))
    end
    
    def to_a
      repository.send_query(self)
    end
    
    def each(&block)
      to_a.each(&block)
    end
    
    def repository
      raise NotImplementedError
    end
  end
end
