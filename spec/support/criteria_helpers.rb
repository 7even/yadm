module CriteriaHelpers
  def build_criteria(components)
    YADM::Criteria.new(components)
  end
  
  def build_condition(expression)
    YADM::Criteria::Condition.new(expression)
  end
  
  def build_order(clauses)
    YADM::Criteria::Order.new(clauses)
  end
  
  def build_order_clause(type, expression)
    YADM::Criteria::Order::Clause.new(type, expression)
  end
  
  def build_limit(limit)
    YADM::Criteria::Limit.new(limit)
  end
  
  def build_expression(receiver, method, argument)
    YADM::Criteria::Expression.new(receiver, method, [argument])
  end
  
  def build_attribute(name)
    YADM::Criteria::Attribute.new(name)
  end
  
  def build_argument(group, index)
    YADM::Criteria::Argument.new(group, index)
  end
end
