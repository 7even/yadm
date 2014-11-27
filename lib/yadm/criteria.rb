require 'yadm/criteria/expression'
require 'yadm/criteria/condition'
require 'yadm/criteria/order'
require 'yadm/criteria/limit'

module YADM
  class Criteria
    attr_reader :condition, :order, :limit
    
    def initialize(condition: nil, order: nil, limit: nil)
      @condition = condition
      @order     = order
      @limit     = limit
    end
    
    def merge(other_criteria)
      self.class.new(
        condition: Condition.merge(condition, other_criteria.condition),
        order:     Order.merge(order, other_criteria.order),
        limit:     Limit.merge(limit, other_criteria.limit)
      )
    end
    
    def ==(other)
      %i(condition order limit).all? do |method|
        other.respond_to?(method) && send(method) == other.send(method)
      end
    end
  end
end
