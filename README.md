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
* mapper
* adapters

### Entities

You can create an entity by defining a class that includes `YADM::Entity`:

``` ruby
class Person
  include YADM::Entity
  
  attributes :id, :first_name, :last_name, :email, :password
end
```

### Repositories

Similarly, repositories are just modules that include `YADM::Repository`:

``` ruby
module People
  include YADM::Repository
  entity Person
  
  class << self
    def unnamed
      with(first_name: nil, last_name: nil)
    end
  end
end
```

### Mapper

Mapper is the central part glueing everything together - it connects
the repositories with the data sources.

``` ruby
YADM.setup do
  postgres = connect(:sql) do
    adapter :postgres
    
    host     'localhost'
    database 'blog'
    user     'user'
    password 'password'
  end
  
  map do
    repo People do
      data_source postgres
      
      table :people
      
      attribute :id,         Integer
      attribute :first_name, String
      attribute :last_name,  String
      attribute :email,      String
      attribute :password,   String
    end
  end
end
```

### Adapters

You can use any adapter as a data source by providing it the connection
parameters.

#### Memory

The memory adapter doesn't need any configuration.

``` ruby
YADM.setup do
  memory = connect(:memory)
  # use `memory` as a data source in some repository
end
```

#### SQL

In order to connect to a database you have to provide connection parameters:

``` ruby
YADM.setup do
  postgres = connect(:sql) do
    adapter :postgres
    
    host     'localhost'
    database 'blog'
    user     'user'
    password 'password'
  end
  
  # use `postgres` as a data source in some repository
end
```

### Creating a new record

``` ruby
john = Person.new(
  first_name: 'John',
  last_name:  'Smith',
  email:      'john@smiths.com',
  password:   'secret'
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
