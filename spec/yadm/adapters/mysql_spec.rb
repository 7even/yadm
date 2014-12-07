require 'yadm/adapters/mysql'

RSpec.describe YADM::Adapters::MySQL do
  subject { described_class.new(database: 'yadm_test', user: 'yadm', password: 'yadm') }
  
  it_behaves_like 'a sequel adapter'
end
