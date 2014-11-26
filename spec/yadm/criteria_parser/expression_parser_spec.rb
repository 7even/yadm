RSpec.describe YADM::CriteriaParser::ExpressionParser do
  let(:block) do
    proc do
      age > 12
    end
  end
  
  subject { described_class.new(block) }
  
  describe '#result' do
    let(:result) { subject.result }
    
    it 'returns a Criteria::Expression' do
      expect(result).to be_a(YADM::Criteria::Expression)
      
      expect(result.receiver).to be_a(YADM::Criteria::Expression::Attribute)
      expect(result.receiver.name).to eq(:age)
      
      expect(result.method_name).to eq(:>)
      expect(result.arguments.first).to eq(12)
    end
  end
end
