guard :rspec, all_on_start: true, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})        { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/support/.+\.rb$}) { 'spec' }
  watch('spec/spec_helper.rb')     { 'spec' }
  
  watch('lib/yadm/adapters/common_sql.rb') { 'spec/yadm/adapters' }
end
