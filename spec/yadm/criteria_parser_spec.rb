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
  YADM::Criteria::Expression::Attribute.new(name)
end

def build_argument(group, index)
  YADM::Criteria::Expression::Argument.new(group, index)
end

RSpec.describe YADM::CriteriaParser do
  describe '.parse' do
    context 'without arguments' do
      let(:block) do
        proc do
          with { age > 12 }.descending_by { age }.ascending_by { id }.first(5)
        end
      end
      
      let(:expected_criteria) do
        build_criteria(
          condition: build_condition(
            build_expression(build_attribute(:age), :>, 12)
          ),
          order: build_order(
            [
              build_order_clause(:desc, build_attribute(:age)),
              build_order_clause(:asc, build_attribute(:id))
            ]
          ),
          limit: build_limit(5)
        )
      end
      
      it 'returns the parsed YADM::Criteria' do
        expect(described_class.parse(block, :first)).to eq(expected_criteria)
      end
    end
    
    context 'with arguments' do
      let(:block) do
        proc do |min_age, limit|
          with { age > min_age }.first(limit)
        end
      end
      
      let(:expected_criteria) do
        build_criteria(
          condition: build_condition(
            build_expression(
              build_attribute(:age),
              :>,
              build_argument(:first, 0)
            )
          ),
          limit: build_limit(build_argument(:first, 1))
        )
      end
      
      it 'returns the parsed YADM::Criteria' do
        expect(described_class.parse(block, :first)).to eq(expected_criteria)
      end
    end
  end
end
