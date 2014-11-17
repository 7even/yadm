require 'yadm/adapters/memory'

RSpec.describe YADM::Adapters::Memory do
  let(:person_attributes) do
    { name: 'John', email: 'john@example.com' }
  end
  
  describe '#get' do
    before(:each) do
      subject.add(:people, person_attributes)
    end
    
    context 'with a valid id' do
      it 'returns the record with the specified id' do
        expect(subject.get(:people, 1)).to eq(person_attributes.merge(id: 1))
      end
    end
    
    context 'with an invalid id' do
      it 'raises' do
        expect {
          subject.get(:people, 11)
        }.to raise_error(KeyError)
      end
    end
  end
  
  describe '#add' do
    it 'adds a new record' do
      expect {
        subject.add(:people, person_attributes)
      }.to change { subject.count(:people) }.by(1)
    end
    
    it 'returns id of the created record' do
      expect(subject.add(:people, person_attributes)).to eq(1)
    end
    
    it 'adds the id attribute to the created object' do
      id = subject.add(:people, person_attributes)
      expect(subject.get(:people, id)[:id]).to eq(id)
    end
    
    it 'increments the id with each record' do
      5.times { subject.add(:people, person_attributes) }
      
      expect(subject.count(:people)).to eq(5)
      expect(subject.get(:people, 5)).to eq(person_attributes.merge(id: 5))
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
  
  describe YADM::Adapters::Memory::Collection do
    describe '#filter' do
      before(:each) do
        subject.add(title: 'First post',  comments_count: 14)
        subject.add(title: 'Second post', comments_count: 7)
        subject.add(title: 'Third post',  comments_count: 17)
      end
      
      let(:condition) do
        attribute = YADM::Criteria::Expression::Attribute.new(:comments_count)
        expression = YADM::Criteria::Expression.new(attribute, :>, [10])
        YADM::Criteria::Condition.new(expression)
      end
      
      it 'returns all records matching the condition' do
        result = subject.filter(subject.all, condition)
        
        expect(result.count).to eq(2)
        expect(result.first[:title]).to eq('First post')
        expect(result.last[:title]).to eq('Third post')
      end
    end
    
    describe '#order' do
      before(:each) do
        now = Time.now
        
        subject.add(name: 'Past',     created_at: now - 5)
        subject.add(name: 'Future',   created_at: now + 5)
        subject.add(name: 'Present',  created_at: now)
        subject.add(name: 'Pre-past', created_at: now - 5)
      end
      
      let(:order) do
        created_at = YADM::Criteria::Expression::Attribute.new(:created_at)
        timestamp_clause = YADM::Criteria::Order::Clause.new(:asc, created_at)
        
        id = YADM::Criteria::Expression::Attribute.new(:id)
        id_clause = YADM::Criteria::Order::Clause.new(:desc, id)
        
        YADM::Criteria::Order.new([timestamp_clause, id_clause])
      end
      
      it 'returns records in the specified order' do
        result = subject.order(subject.all, order)
        names  = result.map { |record| record[:name] }
        
        expect(names).to eq(%w(Pre-past Past Present Future))
      end
    end
    
    describe '#limit' do
      before(:each) do
        subject.add(name: 'First')
        subject.add(name: 'Second')
        subject.add(name: 'Third')
      end
      
      let(:limit) { YADM::Criteria::Limit.new(2) }
      
      it 'returns first N records' do
        result = subject.limit(subject.all, limit)
        
        expect(result.count).to eq(2)
        expect(result.first[:name]).to eq('First')
        expect(result.last[:name]).to eq('Second')
      end
    end
  end
end
