RSpec.describe YADM::Adapters do
  describe '.register' do
    let(:adapter) { double('Adapter') }
    
    it 'stores a new adapter in the registry' do
      subject.register(:some_adapter, adapter)
      expect(subject.fetch(:some_adapter)).to eq(adapter)
    end
  end
  
  describe '.fetch' do
    context 'with a registered adapter name' do
      let(:adapter) { double('Adapter') }
      
      before(:each) do
        subject.register(:some_adapter, adapter)
      end
      
      it 'returns the corresponding adapter' do
        expect(subject.fetch(:some_adapter)).to eq(adapter)
      end
    end
    
    context 'with an unknown adapter_name' do
      it 'raises a NotImplementedError' do
        expect {
          subject.fetch(:unknown)
        }.to raise_error(NotImplementedError, "Adapter `:unknown` isn't registered.")
      end
    end
  end
end
