require 'yadm/adapters/memory_adapter'

RSpec.describe YADM::Adapters do
  describe '.fetch' do
    context 'with a :memory parameter' do
      it 'returns MemoryAdapter' do
        expect(subject.fetch(:memory)).to eq(YADM::Adapters::MemoryAdapter)
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
