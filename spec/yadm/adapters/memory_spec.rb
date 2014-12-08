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
    
    it 'adds the id attribute to the created record' do
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
  
  describe '#migrate' do
    it 'does nothing' do
      expect {
        subject.migrate(:block)
      }.not_to raise_error
    end
  end
  
  describe YADM::Adapters::Memory::Collection do
    describe '#send_query' do
      let(:criteria) do
        YADM::Criteria.new(
          condition: :some_condition,
          order: :some_order,
          limit: :some_limit
        )
      end
      
      let(:query) { double('Query', criteria: criteria, arguments: {}) }
      
      let(:records) { %i(first second third fourth) }
      let(:filtered_records) { %i(first third fourth) }
      let(:ordered_records) { %i(third first fourth) }
      let(:limited_records) { %i(third first) }
      
      before(:each) do
        allow(subject).to receive(:all).and_return(records)
      end
      
      it 'returns the transformed records collection' do
        expect(subject).to receive(:filter).with(records, :some_condition, {}).and_return(filtered_records)
        expect(subject).to receive(:order).with(filtered_records, :some_order, {}).and_return(ordered_records)
        expect(subject).to receive(:limit).with(ordered_records, :some_limit, {}).and_return(limited_records)
        
        expect(subject.send_query(query)).to eq(limited_records)
      end
    end
    
    describe '#filter' do
      before(:each) do
        subject.add(title: 'First post',  comments_count: 14)
        subject.add(title: 'Second post', comments_count: 7)
        subject.add(title: 'Third post',  comments_count: 17)
      end
      
      let(:condition) do
        attribute  = build_attribute(:comments_count)
        expression = build_expression(attribute, :>, 10)
        
        build_condition(expression)
      end
      
      it 'returns all records matching the condition' do
        result = subject.filter(subject.all, condition, {})
        
        expect(result.count).to eq(2)
        expect(result.first[:title]).to eq('First post')
        expect(result.last[:title]).to eq('Third post')
      end
      
      context 'with arguments' do
        let(:condition) do
          attribute  = build_attribute(:comments_count)
          argument   = build_argument(:first, 0)
          expression = build_expression(attribute, :>, argument)
          
          build_condition(expression)
        end
        
        it 'returns all records matching the condition' do
          result = subject.filter(subject.all, condition, first: [15])
          
          expect(result.count).to eq(1)
          expect(result.first[:title]).to eq('Third post')
        end
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
        created_at = build_attribute(:created_at)
        timestamp_clause = build_order_clause(:asc, created_at)
        
        id = build_attribute(:id)
        id_clause = build_order_clause(:desc, id)
        
        build_order([timestamp_clause, id_clause])
      end
      
      it 'returns records in the specified order' do
        result = subject.order(subject.all, order, {})
        names  = result.map { |record| record[:name] }
        
        expect(names).to eq(%w(Pre-past Past Present Future))
      end
      
      context 'with arguments' do
        let(:order) do
          name       = build_attribute(:name)
          argument   = build_argument(:first, 0)
          expression = build_expression(name, :[], argument)
          
          clause = build_order_clause(:asc, expression)
          build_order([clause])
        end
        
        it 'returns records in the specified order' do
          result = subject.order(subject.all, order, first: [1])
          names = result.map { |record| record[:name] }
          
          expect(names).to eq(%w(Past Present Pre-past Future))
        end
      end
    end
    
    describe '#limit' do
      before(:each) do
        subject.add(name: 'First')
        subject.add(name: 'Second')
        subject.add(name: 'Third')
      end
      
      let(:limit) { build_limit(2) }
      
      it 'returns first N records' do
        result = subject.limit(subject.all, limit, {})
        
        expect(result.count).to eq(2)
        expect(result.first[:name]).to eq('First')
        expect(result.last[:name]).to eq('Second')
      end
      
      context 'with arguments' do
        let(:limit) do
          argument = build_argument(:first, 0)
          build_limit(argument)
        end
        
        it 'returns first N records' do
          result = subject.limit(subject.all, limit, first: [1])
          expect(result.count).to eq(1)
        end
      end
    end
  end
end
