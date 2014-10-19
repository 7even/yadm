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
  
  describe '#add' do
    it 'saves the object in the data source' do
      subject.add(:people, name: 'Jack')
      
      expect(data_source.get(:people, 2)[:name]).to eq('Jack')
    end
    
    it 'saves the object in the map' do
      subject.add(:people, name: 'Jack')
      
      expect(data_source).not_to receive(:get)
      expect(subject.get(:people, 2)[:id]).to eq(2)
    end
    
    it 'returns the id of the added record' do
      expect(subject.add(:people, name: 'Jack')).to eq(2)
    end
  end
  
  describe '#change' do
    context 'without an object in map' do
      before(:each) do
        subject.change(:people, 1, name: 'David')
      end
      
      it 'changes the object in the data source' do
        expect(data_source.get(:people, 1)[:name]).to eq('David')
      end
      
      it 'adds the object to the map' do
        expect(data_source).not_to receive(:get)
        expect(subject.get(:people, 1)[:id]).to eq(1)
      end
    end
    
    context 'with an object in map' do
      before(:each) do
        subject.get(:people, 1)
        subject.change(:people, 1, name: 'David')
      end
      
      it 'updates the object in the map' do
        expect(data_source).not_to receive(:get)
        expect(subject.get(:people, 1)[:name]).to eq('David')
      end
    end
  end
  
  describe '#remove' do
    it 'removes the object from the data source' do
      subject.remove(:people, 1)
      expect(data_source.count(:people)).to be_zero
    end
    
    context 'with an object in map' do
      before(:each) do
        subject.get(:people, 1)
        subject.remove(:people, 1)
      end
      
      it 'removes the object from the map' do
        expect(data_source).to receive(:get).with(:people, 1).and_call_original
        
        expect {
          subject.get(:people, 1)
        }.to raise_error(KeyError)
      end
    end
  end
end
