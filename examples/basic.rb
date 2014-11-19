# use with `pry -r ./examples/basic.rb`
$LOAD_PATH << File.expand_path('../../lib')
require 'yadm'
require 'yadm/adapters/memory'

class Person
  include YADM::Entity
  attributes :first_name, :last_name, :age
end

module People
  include YADM::Repository
  entity Person
end

YADM.setup do
  data_source :store, adapter: :memory
  
  map do
    repository People do
      data_source :store
      collection  :people
      
      attribute :id, Integer
      attribute :first_name, String
      attribute :last_name, String
      attribute :age, Integer
    end
  end
end

[
  Person.new(first_name: 'Vsevolod', last_name: 'Romashov', age: 30),
  Person.new(first_name: 'Alexey', last_name: 'Kurepin', age: 29)
].each { |person| People.persist(person) }
