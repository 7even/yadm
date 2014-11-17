# YADM - Yet Another Data Mapper

Another attempt to implement Data Mapper in ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yadm'
```

And then execute:

``` sh
$ bundle
```

Or install it yourself as:

``` sh
$ gem install yadm
```

## Usage

Data Mapper consists of several components:

* entities
* repositories
* data sources
* mapper

### Entities

Entity is a basic object with some attributes.

You can create an entity by defining a class that includes `YADM::Entity`:

``` ruby
class Person
  include YADM::Entity
  
  attributes :first_name, :last_name, :email, :password, :age
end
```

### Repositories

A repository is a module representing a collection of entities. It can fetch
the objects from the data store and persist the changes back. Here you can
build complex queries to the data source.

A repository is created as a module that includes `YADM::Repository`
and specifies it's entity:

``` ruby
module People
  include YADM::Repository
  entity Person
  
  query :unnamed do
    with { first_name.nil? & last_name.nil? }
    # OR
    without { first_name }.without { last_name }
  end
  
  query :kids do
    with { age < 12 }
  end
  
  query :older_than do |min_age|
    with { age > min_age }
  end
  
  query :in_alphabetical_order do
    ascending_by { last_name }.ascending_by { first_name }
  end
  
  query :oldest do |count = 10|
    descending_by(:age).first(count)
  end
end
```

### Data sources

Data sources are objects that encapsulate the knowledge how to read the data
and write it back. They are defined by adapters for different
data storage solutions; YADM ships with the memory adapter.

You can register a data source with your own unique name
(specifying the adapter):

``` ruby
YADM.setup do
  data_source :memory_store, adapter: :memory
end
```

### Mapper

Mapper is the central part glueing everything together - it connects
repositories to data sources.

Assuming the `memory_store` data source created earlier
we can link the repository to it and define some attributes:

``` ruby
YADM.setup do
  map do
    repository People do
      data_source :memory_store
      collection  :people
      
      attribute :id,         Integer
      attribute :first_name, String
      attribute :last_name,  String
      attribute :email,      String
      attribute :password,   String
      attribute :age,        Integer
    end
  end
end
```

### Creating a new record

``` ruby
john = Person.new(
  first_name: 'John',
  last_name:  'Smith',
  email:      'john@smiths.com',
  password:   'secret',
  age:        28
)

People.persist(john)

john.persisted? # => true
jonh.id         # => 1
```

### Updating a record

``` ruby
john.password = 'f1E2m0CdP'
People.persist(john)
```

### Deleting a record

``` ruby
People.delete(john)

john.persisted? # => false
```

## Contributing

1. Fork it (https://github.com/7even/yadm/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
