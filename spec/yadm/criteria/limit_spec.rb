RSpec.describe YADM::Criteria::Limit do
  describe '.merge' do
    let(:first_limit)  { described_class.new(10) }
    let(:second_limit) { described_class.new(15) }
    
    subject { described_class.merge(first_limit, second_limit) }
    
    it 'respects the last value' do
      expect(subject.limit).to eq(15)
    end
    
    context 'with second argument having a nil limit' do
      let(:second_limit) { described_class.new(nil) }
      
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
    
    context 'with first argument being nil' do
      let(:first_limit) { nil }
      
      it 'returns the second argument' do
        expect(subject).to eq(second_limit)
      end
    end
    
    context 'with second argument being nil' do
      let(:second_limit) { nil }
      
      it 'returns the first argument' do
        expect(subject).to eq(first_limit)
      end
    end
    
    context 'with both arguments being nil' do
      let(:first_limit)  { nil }
      let(:second_limit) { nil }
      
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end
end
