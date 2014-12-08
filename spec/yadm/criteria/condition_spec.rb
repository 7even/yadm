RSpec.describe YADM::Criteria::Condition do
  describe '.merge' do
    let(:first_condition) do
      attribute  = build_attribute(:age)
      expression = build_expression(attribute, :>, 20)
      
      described_class.new(expression)
    end
    
    let(:second_condition) do
      attribute  = build_attribute(:age)
      expression = build_expression(attribute, :<, 35)
      
      described_class.new(expression)
    end
    
    subject { described_class.merge(first_condition, second_condition) }
    
    it 'concatenates the conditions with a logical AND' do
      expect(subject.expression.receiver).to eq(first_condition.expression)
      expect(subject.expression.method_name).to eq(:&)
      expect(subject.expression.arguments).to eq([second_condition.expression])
    end
    
    context 'with first argument being nil' do
      let(:first_condition) { nil }
      
      it 'returns the second argument' do
        expect(subject).to eq(second_condition)
      end
    end
    
    context 'with second argument being nil' do
      let(:second_condition) { nil }
      
      it 'returns the first argument' do
        expect(subject).to eq(first_condition)
      end
    end
    
    context 'with both arguments being nil' do
      let(:first_condition)  { nil }
      let(:second_condition) { nil }
      
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end
end
