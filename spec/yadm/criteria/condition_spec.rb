RSpec.describe YADM::Criteria::Condition do
  describe '.merge' do
    let(:first_condition) do
      attribute = YADM::Criteria::Expression::Attribute.new(:age)
      expression = YADM::Criteria::Expression.new(attribute, :>, [20])
      described_class.new(expression)
    end
    
    let(:second_condition) do
      attribute = YADM::Criteria::Expression::Attribute.new(:age)
      expression = YADM::Criteria::Expression.new(attribute, :<, [35])
      described_class.new(expression)
    end
    
    it 'concatenates the conditions with a logical AND' do
      result_condition = described_class.merge(first_condition, second_condition)
      
      expect(result_condition.expression.receiver).to eq(first_condition.expression)
      expect(result_condition.expression.method_name).to eq(:&)
      expect(result_condition.expression.arguments).to eq([second_condition.expression])
    end
  end
end
