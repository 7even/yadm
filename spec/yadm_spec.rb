require 'yadm/adapters/memory_adapter'

RSpec.describe YADM do
  describe '.setup' do
    it "evaluates the block in context of YADM itself" do
      module_name = nil
      YADM.setup do
        module_name = name
      end
      
      expect(module_name).to eq('YADM')
    end
  end
  
  describe '.data_source' do
    before(:each) do
      YADM.setup do
        data_source :memory_store, adapter: :memory
      end
    end
    
    it 'creates a data source wrapped in an identity map' do
      data_source = YADM.data_sources[:memory_store]
      
      expect(data_source).to be_a(YADM::IdentityMap)
      expect(data_source.send(:data_source)).to be_a(YADM::Adapters::MemoryAdapter)
    end
  end
end
