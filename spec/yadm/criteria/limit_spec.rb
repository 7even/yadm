RSpec.describe YADM::Criteria::Limit do
  describe '.merge' do
    let(:first_limit)  { described_class.new(10) }
    let(:second_limit) { described_class.new(15) }
    
    it 'respects the last value' do
      result = described_class.merge(first_limit, second_limit)
      expect(result.limit).to eq(15)
    end
  end
end
