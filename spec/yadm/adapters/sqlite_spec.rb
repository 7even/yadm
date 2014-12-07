require 'yadm/adapters/sqlite'

RSpec.describe YADM::Adapters::Sqlite do
  it_behaves_like 'a sequel adapter'
end
