require 'yadm/adapters/memory_adapter'

RSpec.describe YADM::Mapping do
  let(:data_source)  { YADM::Adapters::MemoryAdapter.new }
  let(:identity_map) { YADM::IdentityMap.new(data_source) }
  
  before(:each) do
    data_source.add(:people, name: 'John', age: '35')
  end
  
  let(:attrs) do
    {
      id:   YADM::Mapping::Attribute.new(Integer),
      name: YADM::Mapping::Attribute.new(String),
      age:  YADM::Mapping::Attribute.new(Integer)
    }
  end
  
  subject do
    YADM::Mapping.new(identity_map, :people, attributes: attrs)
  end
  
  describe '#get' do
    it 'returns a hash with converted attributes' do
      hash = subject.get(1)
      
      expect(hash[:id]).to eq(1)
      expect(hash[:name]).to eq('John')
      expect(hash[:age]).to eq(35)
    end
  end
end
