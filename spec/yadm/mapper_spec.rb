RSpec.describe YADM::Mapper do
  let(:identity_map) { YADM::IdentityMap.new(nil) }
  
  before(:each) do
    YADM.data_sources[:source] = identity_map
  end
  
  describe '.repository' do
    let(:repository) do
      Class.new do
        include YADM::Repository
      end
    end
    
    it 'adds a new mapping for the given repository' do
      subject.repository(repository) do
        data_source :source
      end
      
      expect(subject.mapping_for(repository).data_source).to eq(identity_map)
    end
  end
end
