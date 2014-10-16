require 'yadm'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  
  config.disable_monkey_patching!
  config.profile_examples = 5
  
  config.order = :random
  Kernel.srand config.seed
end
