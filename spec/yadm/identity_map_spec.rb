require 'yadm/adapters/memory'

RSpec.describe YADM::IdentityMap do
  let(:data_source) { YADM::Adapters::Memory.new }
  
  before(:each) do
    data_source.add(:people, name: 'John')
  end
  
  subject { YADM::IdentityMap.new(data_source) }
  
  describe '#get' do
    context 'without a record in map' do
      it 'gets the record from the data source' do
        expect(subject.get(:people, 1)).to eq(id: 1, name: 'John')
      end
    end
    
    context 'with a record in map' do
      before(:each) do
        subject.get(:people, 1)
        data_source.change(:people, 1, name: 'Jack')
      end
      
      it 'gets the record from the map' do
        expect(subject.get(:people, 1)).to eq(id: 1, name: 'John')
      end
    end
  end
  
  describe '#add' do
    it 'saves the record in the data source' do
      subject.add(:people, name: 'Jack')
      
      expect(data_source.get(:people, 2)[:name]).to eq('Jack')
    end
    
    it 'saves the record in the map' do
      subject.add(:people, name: 'Jack')
      
      expect(data_source).not_to receive(:get)
      expect(subject.get(:people, 2)[:id]).to eq(2)
    end
    
    it 'returns the id of the added record' do
      expect(subject.add(:people, name: 'Jack')).to eq(2)
    end
  end
  
  describe '#change' do
    context 'without a record in map' do
      before(:each) do
        subject.change(:people, 1, name: 'David')
      end
      
      it 'changes the record in the data source' do
        expect(data_source.get(:people, 1)[:name]).to eq('David')
      end
      
      it 'adds the record to the map' do
        expect(data_source).not_to receive(:get)
        expect(subject.get(:people, 1)[:id]).to eq(1)
      end
    end
    
    context 'with a record in map' do
      before(:each) do
        subject.get(:people, 1)
        subject.change(:people, 1, name: 'David')
      end
      
      it 'updates the record in the map' do
        expect(data_source).not_to receive(:get)
        expect(subject.get(:people, 1)[:name]).to eq('David')
      end
    end
  end
  
  describe '#remove' do
    it 'removes the record from the data source' do
      subject.remove(:people, 1)
      expect(data_source.count(:people)).to be_zero
    end
    
    context 'with a record in map' do
      before(:each) do
        subject.get(:people, 1)
        subject.remove(:people, 1)
      end
      
      it 'removes the record from the map' do
        expect(data_source).to receive(:get).with(:people, 1).and_call_original
        
        expect {
          subject.get(:people, 1)
        }.to raise_error(KeyError)
      end
    end
  end
  
  describe '#count' do
    it 'passes the method call to the data source' do
      expect(subject.count(:people)).to eq(1)
    end
  end
  
  describe '#send_query' do
    let(:query) { double('Query') }
    let(:data)  { double('Data') }
    
    before(:each) do
      allow(data_source).to receive(:send_query).with(:people, query).and_return(data)
    end
    
    it 'passes the method call to the data source' do
      expect(subject.send_query(:people, query)).to eq(data)
    end
  end
  
  describe '#migrate' do
    let(:block) { double('Block') }
    
    it 'passes the method call to the data source' do
      expect(data_source).to receive(:migrate).with(block)
      subject.migrate(block)
    end
  end
end
