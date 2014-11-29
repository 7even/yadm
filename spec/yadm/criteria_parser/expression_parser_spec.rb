RSpec.describe YADM::CriteriaParser::ExpressionParser do
  subject { described_class.new(block) }
  
  describe '#result' do
    let(:result) { subject.result }
    
    context 'with a simple block' do
      let(:block) do
        proc do
          age > 12
        end
      end
      
      let(:expected_expression) do
        build_expression(build_attribute(:age), :>, 12)
      end
      
      it 'returns a Criteria::Expression' do
        expect(result).to eq(expected_expression)
      end
    end
    
    context 'with a nested expression in the block' do
      let(:block) do
        proc do
          (age >= 18) & (age <= 27) & (sex == 'male')
        end
      end
      
      let(:expected_expression) do
        build_expression(
          build_expression(
            build_expression(build_attribute(:age), :>=, 18),
            :&,
            build_expression(build_attribute(:age), :<=, 27)
          ),
          :&,
          build_expression(build_attribute(:sex), :==, 'male')
        )
      end
      
      it 'returns a nested Criteria::Expression' do
        expect(result).to eq(expected_expression)
      end
    end
  end
end
