RSpec.describe YADM::Mapping::Attribute do
  context 'with an Integer type' do
    subject { described_class.new(Integer) }
    
    describe '#coerce' do
      it 'coerces the value to integer' do
        expect(subject.coerce('123')).to eq(123)
        expect(subject.coerce(123)).to eq(123)
        expect(subject.coerce('123abc')).to eq(123)
        expect(subject.coerce('abc')).to eq(0)
      end
      
      it 'leaves nil as is' do
        expect(subject.coerce(nil)).to be_nil
      end
    end
  end
  
  context 'with a String type' do
    subject { described_class.new(String) }
    
    describe '#coerce' do
      it 'coerces the value to String' do
        expect(subject.coerce(123)).to eq('123')
        expect(subject.coerce('123')).to eq('123')
        expect(subject.coerce('123abc')).to eq('123abc')
        expect(subject.coerce(:abc)).to eq('abc')
      end
      
      it 'leaves nil as is' do
        expect(subject.coerce(nil)).to be_nil
      end
    end
  end
end
