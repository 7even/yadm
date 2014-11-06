RSpec.describe YADM::Criteria::Order do
  describe '.merge' do
    let(:first_order) do
      attribute = YADM::Criteria::Expression::Attribute.new(:last_name)
      clause = YADM::Criteria::Order::Clause.new(:asc, attribute)
      
      described_class.new([clause])
    end
    
    let(:second_order) do
      attribute = YADM::Criteria::Expression::Attribute.new(:first_name)
      clause = YADM::Criteria::Order::Clause.new(:asc, attribute)
      
      described_class.new([clause])
    end
    
    it 'sums up the clauses' do
      result = described_class.merge(first_order, second_order)
      
      expect(result.clauses.count).to eq(2)
      expect(result.clauses.first).to eq(first_order.clauses.first)
      expect(result.clauses.last).to eq(second_order.clauses.first)
    end
  end
end
