require 'yadm/adapters/common_sql'

RSpec.describe YADM::Adapters::CommonSQL do
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
          result = described_class.sequelize(expression, {})
          
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
        result = described_class.sequelize(expression, {})
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
        result = described_class.sequelize(expression, {})
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
        result = described_class.sequelize(expression, {})
        expect(result.op).to eq(:OR)
      end
    end
    
    context 'with arguments' do
      let(:expression) do
        build_expression(
          build_attribute(:comments_count),
          :>,
          build_argument(:first, 0)
        )
      end
      
      it "creates an expression with argument replaced with it's value" do
        result = described_class.sequelize(expression, first: [20])
        expect(result.args.last).to eq(20)
      end
    end
  end
end
