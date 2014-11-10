RSpec.describe YADM::Criteria do
  describe '#merge' do
    subject do
      described_class.new(
        condition: :first_condition,
        order:     :first_order,
        limit:     :first_limit
      )
    end
    
    let(:other_criteria) do
      described_class.new(
        condition: :second_condition,
        order:     :second_order,
        limit:     :second_limit
      )
    end
    
    before(:each) do
      allow(YADM::Criteria::Condition).to receive(:merge).and_return(:third_condition)
      allow(YADM::Criteria::Order).to receive(:merge).and_return(:third_order)
      allow(YADM::Criteria::Limit).to receive(:merge).and_return(:third_limit)
    end
    
    it 'merges conditions' do
      expect(YADM::Criteria::Condition).to receive(:merge).with(:first_condition, :second_condition)
      expect(subject.merge(other_criteria).condition).to eq(:third_condition)
    end
    
    it 'merges orders' do
      expect(YADM::Criteria::Order).to receive(:merge).with(:first_order, :second_order)
      expect(subject.merge(other_criteria).order).to eq(:third_order)
    end
    
    it 'merges limits' do
      expect(YADM::Criteria::Limit).to receive(:merge).with(:first_limit, :second_limit)
      expect(subject.merge(other_criteria).limit).to eq(:third_limit)
    end
  end
end
