require 'yadm/adapters/sqlite'

RSpec.describe YADM::Adapters::Sqlite do
  let(:connection) { subject.send(:connection) }
  
  before(:each) do
    connection.create_table :people do
      primary_key :id
      
      String :name
      String :email
    end
  end
  
  let(:person_attributes) do
    { name: 'John', email: 'john@example.com' }
  end
  
  describe '#get' do
    before(:each) do
      subject.add(:people, person_attributes)
    end
    
    it 'returns the record with the specified id' do
      expect(subject.get(:people, 1)).to eq(person_attributes.merge(id: 1))
    end
  end
  
  describe '#add' do
    it 'adds a new record' do
      expect {
        subject.add(:people, person_attributes)
      }.to change { subject.count(:people) }.by(1)
    end
    
    it 'returns the id of the created record' do
      expect(subject.add(:people, person_attributes)).to eq(1)
    end
  end
  
  describe '#change' do
    before(:each) do
      subject.add(:people, person_attributes)
    end
    
    it 'changes an existing record' do
      expect {
        subject.change(:people, 1, name: 'Jack')
      }.to change { subject.get(:people, 1)[:name] }.to('Jack')
    end
  end
  
  describe '#remove' do
    before(:each) do
      subject.add(:people, person_attributes)
    end
    
    it 'removes the record with the specified id' do
      expect {
        subject.remove(:people, 1)
      }.to change { subject.count(:people) }.by(-1)
    end
  end
end
