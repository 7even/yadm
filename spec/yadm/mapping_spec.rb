require 'yadm/adapters/memory_adapter'

RSpec.describe YADM::Mapping do
  let(:data_source)  { YADM::Adapters::MemoryAdapter.new }
  let(:identity_map) { YADM::IdentityMap.new(data_source) }
  
  before(:each) do
    data_source.add(:people, name: 'John', age: '35')
    YADM.data_sources[:source] = identity_map
  end
  
  let(:people_mapping) do
    YADM::Mapping.new do
      data_source :source
      collection  :people
      
      attribute :id, Integer
      attribute :name, String
      attribute :age, Integer
    end
  end
  
  describe '#get' do
    it 'returns a hash with converted attributes' do
      hash = people_mapping.get(1)
      
      expect(hash[:id]).to eq(1)
      expect(hash[:name]).to eq('John')
      expect(hash[:age]).to eq(35)
    end
  end
  
  describe '#add' do
    it 'passes the method call to the data source' do
      people_mapping.add(name: 'Jack', age: 27)
      expect(people_mapping.get(2)[:name]).to eq('Jack')
    end
  end
  
  describe '#change' do
    it 'passes the method call to the data source' do
      people_mapping.change(1, name: 'Johnny')
      expect(people_mapping.get(1)[:name]).to eq('Johnny')
    end
  end
  
  describe '#remove' do
    it 'passes the method call to the data source' do
      people_mapping.remove(1)
      expect { people_mapping.get(1) }.to raise_error(KeyError)
    end
  end
  
  describe YADM::Mapping::DSL do
    describe '#data_source' do
      let(:mapping) do
        YADM::Mapping.new do
          data_source :source
        end
      end
      
      it 'specifies the data source identifier' do
        expect(mapping.data_source).to eq(identity_map)
      end
    end
    
    describe '#collection' do
      let(:mapping) do
        YADM::Mapping.new do
          collection :people
        end
      end
      
      it 'specifies the collection' do
        expect(mapping.collection).to eq(:people)
      end
    end
    
    describe '#attribute' do
      let(:mapping) do
        YADM::Mapping.new do
          attribute :id, Integer
        end
      end
      
      it 'adds a new attribute' do
        expect(mapping.attributes).to have_key(:id)
        expect(mapping.attributes[:id]).to eq(YADM::Mapping::Attribute.new(Integer))
      end
    end
  end
end
