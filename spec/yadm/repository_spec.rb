require 'ostruct'

RSpec.describe YADM::Repository do
  let(:repository) do
    Class.new do
      include YADM::Repository
      entity OpenStruct
    end
  end
  
  before(:each) do
    attributes = { id: 1, first_name: 'John', last_name: 'Smith' }
    
    mapping = double("Mapping")
    allow(mapping).to receive(:get).with(1).and_return(attributes)
    
    mapper = double("Mapper")
    allow(mapper).to receive(:mapping_for).with(repository).and_return(mapping)
    
    allow(YADM).to receive(:mapper).and_return(mapper)
  end
  
  describe '.find' do
    it 'gets the record by id' do
      record = repository.find(1)
      
      expect(record.id).to eq(1)
      expect(record.first_name).to eq('John')
      expect(record.last_name).to eq('Smith')
    end
  end
end
