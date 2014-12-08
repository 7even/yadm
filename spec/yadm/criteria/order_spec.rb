RSpec.describe YADM::Criteria::Order do
  describe '.merge' do
    let(:first_order) do
      attribute = build_attribute(:last_name)
      clause    = build_order_clause(:asc, attribute)
      
      described_class.new([clause])
    end
    
    let(:second_order) do
      attribute = build_attribute(:first_name)
      clause    = build_order_clause(:asc, attribute)
      
      described_class.new([clause])
    end
    
    subject { described_class.merge(first_order, second_order) }
    
    it 'sums up the clauses' do
      expect(subject.clauses.count).to eq(2)
      expect(subject.clauses.first).to eq(first_order.clauses.first)
      expect(subject.clauses.last).to eq(second_order.clauses.first)
    end
    
    context 'with first argument being nil' do
      let(:first_order) { nil }
      
      it 'returns the second argument' do
        expect(subject).to eq(second_order)
      end
    end
    
    context 'with second argument being nil' do
      let(:second_order) { nil }
      
      it 'returns the first argument' do
        expect(subject).to eq(first_order)
      end
    end
    
    context 'with both arguments being nil' do
      let(:first_order)  { nil }
      let(:second_order) { nil }
      
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end
end
