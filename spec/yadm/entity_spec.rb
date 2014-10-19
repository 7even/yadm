RSpec.describe YADM::Entity do
  let(:entity_class) do
    Class.new do
      include YADM::Entity
    end
  end
  
  describe '.attributes' do
    before(:each) do
      entity_class.class_eval do
        attributes :name
      end
    end
    
    let(:entity) { entity_class.new(id: 1, name: 'John') }
    
    it 'defines a constructor that takes specified attributes' do
      expect(entity.id).to eq(1)
      expect(entity.name).to eq('John')
    end
    
    it 'defines accessors' do
      entity.name = 'Jack'
      expect(entity.name).to eq('Jack')
    end
    
    context 'with string parameters' do
      before(:each) do
        entity_class.class_eval do
          attribute 'email'
        end
      end
      
      let(:entity) do
        entity_class.new(id: 1, name: 'John', email: 'john@example.com')
      end
      
      it 'behaves the same as with symbol parameters' do
        expect(entity.email).to eq('john@example.com')
      end
    end
    
    context 'with string keys in contructor' do
      let(:entity) { entity_class.new('id' => 1, 'name' => 'John') }
      
      it 'behaves the same as with symbol keys' do
        expect(entity.id).to eq(1)
        expect(entity.name).to eq('John')
      end
    end
    
    context 'without arguments' do
      it 'returns all attribute names' do
        expect(entity_class.attributes).to eq([:id, :name].to_set)
      end
    end
  end
end
