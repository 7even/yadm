require 'yadm/adapters/memory'

RSpec.describe YADM::Mapping do
  let(:data_source)  { YADM::Adapters::Memory.new }
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
  
  describe '#count' do
    it 'passes the method call to the data source' do
      expect(people_mapping.count).to eq(1)
    end
  end
  
  describe '#send_query' do
    let(:query) { double('Query') }
    
    let(:data) do
      [
        { id: 1, name: 'John', age: '31' },
        { id: 2, name: 'Jack', age: '42' }
      ]
    end
    
    before(:each) do
      allow(identity_map).to receive(:send_query).with(:people, query).and_return(data)
    end
    
    it 'gets the data from the data source and coerces it' do
      result = people_mapping.send_query(query)
      
      expect(result.first[:name]).to eq('John')
      expect(result.first[:age]).to eq(31)
      expect(result.last[:name]).to eq('Jack')
      expect(result.last[:age]).to eq(42)
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
