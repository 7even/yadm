require 'yadm/adapters/memory_adapter'

RSpec.describe YADM::IdentityMap do
  let(:data_source) { YADM::Adapters::MemoryAdapter.new }
  
  before(:each) do
    data_source.add(:people, name: 'John')
  end
  
  subject { YADM::IdentityMap.new(data_source) }
  
  describe '#get' do
    context 'without an object in map' do
      it 'gets the object from the data source' do
        expect(subject.get(:people, 1)).to eq(id: 1, name: 'John')
      end
    end
    
    context 'with an object in map' do
      before(:each) do
        subject.get(:people, 1)
        data_source.change(:people, 1, name: 'Jack')
      end
      
      it 'gets the object from the map' do
        expect(subject.get(:people, 1)).to eq(id: 1, name: 'John')
      end
    end
  end
end
