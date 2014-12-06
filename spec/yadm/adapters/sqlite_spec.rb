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
  
  describe '#send_query' do
    before(:each) do
      connection.create_table :posts do
        primary_key :id
        
        String  :title
        Integer :comments_count
        Date    :created_at
      end
      
      now = Time.now
      
      [
        ['First',  7,  now - 15],
        ['Second', 10, now - 20],
        ['Third',  4,  now - 10],
        ['Fourth', 13, now]
      ].each do |title, comments_count, created_at|
        subject.add(
          :posts,
          title:          title,
          comments_count: comments_count,
          created_at:     created_at
        )
      end
    end
    
    let(:criteria) do
      build_criteria(
        condition: build_condition(
          build_expression(build_attribute(:comments_count), :<, 10)
        )
      )
    end
    
    let(:query) { YADM::Query.new(criteria, {}) }
    
    it 'filters the records' do
      data = subject.send_query(:posts, query)
      expect(data.count).to eq(2)
    end
  end
  
  describe '.sequelize' do
    %i(< > <= >= + - * / !=).each do |operator|
      context "with '#{operator}' operator" do
        let(:expression) do
          build_expression(
            build_attribute(:comments_count),
            operator,
            1
          )
        end
        
        it "creates an expression with '#{operator}' operator" do
          result = described_class.sequelize(expression)
          
          expect(result.args.first).to eq(Sequel::SQL::Identifier.new(:comments_count))
          expect(result.op).to eq(operator)
          expect(result.args.last).to eq(1)
        end
      end
    end
    
    context "with '==' operator" do
      let(:expression) do
        build_expression(build_attribute(:comments_count), :==, 10)
      end
      
      it "creates an expression with '=' operator" do
        result = described_class.sequelize(expression)
        expect(result.op).to eq(:'=')
      end
    end
    
    context "with '&' operator" do
      let(:subexpression1) do
        build_expression(build_attribute(:comments_count), :>, 25)
      end
      
      let(:subexpression2) do
        build_expression(build_attribute(:comments_count), :<=, 30)
      end
      
      let(:expression) do
        build_expression(subexpression1, :&, subexpression2)
      end
      
      it "creates an expression with 'AND' operator" do
        result = described_class.sequelize(expression)
        expect(result.op).to eq(:AND)
      end
    end
    
    context "with '|' operator" do
      let(:subexpression1) do
        build_expression(build_attribute(:comments_count), :<, 25)
      end
      
      let(:subexpression2) do
        build_expression(build_attribute(:comments_count), :>, 40)
      end
      
      let(:expression) do
        build_expression(subexpression1, :|, subexpression2)
      end
      
      it "creates an expression with 'OR' operator" do
        result = described_class.sequelize(expression)
        expect(result.op).to eq(:OR)
      end
    end
  end
end
