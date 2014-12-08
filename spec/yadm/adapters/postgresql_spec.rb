require 'yadm/adapters/postgresql'

RSpec.describe YADM::Adapters::PostgreSQL do
  subject do
    described_class.new(database: 'yadm_test', user: 'yadm', password: 'yadm')
  end
  
  it_behaves_like 'a sequel adapter'
end
