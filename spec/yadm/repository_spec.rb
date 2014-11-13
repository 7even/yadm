require 'yadm/adapters/memory'

RSpec.describe YADM::Repository do
  let(:entity_class) do
    Class.new do
      include YADM::Entity
      attributes :first_name, :last_name
    end
  end
  
  let(:repository) do
    person = entity_class
    
    Module.new do
      include YADM::Repository
      entity person
    end
  end
  
  before(:each) do
    YADM.data_source :memory_store, adapter: :memory
    
    mapper = YADM::Mapper.new.tap do |mapper|
      mapper.repository(repository) do
        data_source :memory_store
        collection  :people
        
        attribute :id,         Integer
        attribute :first_name, String
        attribute :last_name,  String
      end
    end
    
    allow(YADM).to receive(:mapper).and_return(mapper)
    
    attributes = { first_name: 'John', last_name: 'Smith' }
    YADM.mapper.mapping_for(repository).add(attributes)
  end
  
  describe '.find' do
    it 'gets the record by id' do
      record = repository.find(1)
      
      expect(record.id).to eq(1)
      expect(record.first_name).to eq('John')
      expect(record.last_name).to eq('Smith')
    end
  end
  
  describe '.persist' do
    context 'with a new object' do
      let(:entity) { entity_class.new(first_name: 'Jack', last_name: 'Sparrow') }
      
      it 'persists the entity and assigns the id to it' do
        repository.persist(entity)
        expect(entity.id).to eq(2)
      end
    end
    
    context 'with an existing object' do
      let(:entity) { entity_class.new(id: 1, first_name: 'Johnny', last_name: 'Smith') }
      
      it 'persists the changes made to the entity' do
        repository.persist(entity)
        expect(repository.find(1).first_name).to eq('Johnny')
      end
    end
  end
  
  describe '.delete' do
    let(:entity) { entity_class.new(id: 1, first_name: 'John', last_name: 'Smith') }
    
    it 'deletes the entity' do
      repository.delete(entity)
      
      expect {
        repository.find(1)
      }.to raise_error(KeyError)
    end
  end
  
  describe '.count' do
    it 'passes the method call to the mapping' do
      expect(repository.count).to eq(1)
    end
  end
  
  describe '.send_query' do
    let(:query) { double('Query') }
    
    let(:data) do
      [
        { id: 1, first_name: 'John', last_name: 'Smith' },
        { id: 2, first_name: 'Jack', last_name: 'Sparrow' }
      ]
    end
    
    before(:each) do
      mapping = YADM.mapper.mapping_for(repository)
      allow(mapping).to receive(:send_query).with(query).and_return(data)
    end
    
    it 'gets the data from the mapping and wraps in an entity' do
      result = repository.send_query(query)
      
      expect(result).to all(be_a(entity_class))
      expect(result.first.last_name).to eq('Smith')
      expect(result.last.first_name).to eq('Jack')
    end
  end
  
  describe '.included' do
    it 'creates a Query class under the repository namespace' do
      expect(repository.const_get(:Query)).to be_a(Class)
      expect(repository.const_get(:Query).superclass).to eq(YADM::Query)
      expect(repository.const_get(:Query).repository).to eq(repository)
    end
  end
  
  describe '.default_query' do
    it 'returns an empty instance of the Query class' do
      expect(repository.default_query).to be_a(repository.const_get(:Query))
    end
  end
  
  after(:each) do
    YADM.data_sources.delete(:memory_store)
  end
end
