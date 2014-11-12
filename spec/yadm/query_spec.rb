RSpec.describe YADM::Query do
  describe '#merge' do
    let(:new_criteria) { YADM::Criteria.new(condition: :some_condition) }
    let(:new_query)    { subject.merge(new_criteria, [1]) }
    
    it 'merges criterias' do
      expect(new_query.criteria.condition).to eq(:some_condition)
      expect(new_query.criteria.order).to be_nil
      expect(new_query.criteria.limit).to be_nil
    end
    
    it 'combines arguments' do
      expect(new_query.arguments).to eq([1])
    end
  end
  
  describe '#to_a' do
    let(:repository) { double('Repository') }
    let(:entity)     { double('Entity') }
    
    before(:each) do
      allow(subject).to receive(:repository).and_return(repository)
      allow(repository).to receive(:send_query).with(subject).and_return([entity])
    end
    
    it 'executes the query and returns the results' do
      expect(subject.to_a).to eq([entity])
    end
  end
  
  describe 'Enumerable methods' do
    let(:first_entity)  { double('First entity') }
    let(:second_entity) { double('Second entity') }
    
    before(:each) do
      allow(subject).to receive(:to_a).and_return([first_entity, second_entity])
    end
    
    it 'use #to_a' do
      expect { |b| subject.each(&b) }.to yield_successive_args(first_entity, second_entity)
      expect(subject.first).to eq(first_entity)
      expect(subject.count).to eq(2)
    end
  end
end
