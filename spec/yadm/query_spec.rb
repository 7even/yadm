RSpec.describe YADM::Query do
  describe '#merge' do
    let(:new_criteria) { YADM::Criteria.new(condition: :some_condition) }
    let(:new_query)    { subject.merge(new_criteria, [1]) }
    
    it 'merges criterias' do
      expect(new_query.criteria.condition).to eq(:some_condition)
      expect(new_query.criteria.order).to be_nil
      expect(new_query.criteria.limit).to be_nil
    end
    
    it 'combines arguments' do
      expect(new_query.arguments).to eq([1])
    end
  end
end
