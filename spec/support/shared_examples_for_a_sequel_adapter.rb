RSpec.shared_examples 'a sequel adapter' do
  let(:connection) { subject.send(:connection) }
  let(:now)        { Time.now }
  
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
  
  describe '#send_query' do
    before(:each) do
      setup_table
    end
    
    let(:criteria) do
      build_criteria(
        condition: build_condition(
          build_expression(build_attribute(:comments_count), :<, 10)
        ),
        order: build_order(
          [
            build_order_clause(:desc, build_attribute(:comments_count))
          ]
        ),
        limit: build_limit(1)
      )
    end
    
    let(:query) { YADM::Query.new(criteria, {}) }
    
    it 'filters, orders and limits the records' do
      data = subject.send_query(:posts, query)
      
      expect(data).to eq([
        id:             1,
        title:          'First',
        comments_count: 7,
        created_at:     now - 10
      ])
    end
  end
  
  describe '#filter' do
    before(:each) do
      setup_table
    end
    
    let(:condition) do
      build_condition(
        build_expression(build_attribute(:comments_count), :<, 10)
      )
    end
    
    it 'returns a dataset with the condition' do
      result = subject.filter(subject.from(:posts), condition, {})
      
      expect(result.count).to eq(2)
      expect(result.to_a.first[:title]).to eq('First')
      expect(result.to_a.last[:title]).to eq('Third')
    end
  end
  
  describe '#order' do
    before(:each) do
      setup_table
    end
    
    let(:order) do
      build_order(
        [
          build_order_clause(:desc, build_attribute(:created_at)),
          build_order_clause(:asc, build_attribute(:comments_count))
        ]
      )
    end
    
    it 'returns a dataset with the specified order' do
      result = subject.order(subject.from(:posts), order, {})
      titles = result.map { |record| record[:title] }
      
      expect(titles).to eq(%w(Fourth Third First Second))
    end
  end
  
  describe '#limit' do
    before(:each) do
      setup_table
    end
    
    let(:limit) { build_limit(2) }
    
    it 'returns a dataset with the specified limit' do
      result = subject.limit(subject.from(:posts), limit, {})
      expect(result.count).to eq(2)
    end
    
    context 'with arguments' do
      let(:limit) { build_limit(build_argument(:first, 0)) }
      
      it 'returns a dataset with the specified limit' do
        result = subject.limit(subject.from(:posts), limit, first: [3])
        expect(result.count).to eq(3)
      end
    end
  end
  
  describe '#migrate' do
    let(:block) { double('Block') }
    
    it 'calls the given block passing it the database connection' do
      expect(block).to receive(:call).with(connection)
      subject.migrate(block)
    end
  end
end
