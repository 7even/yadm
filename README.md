# YADM - Yet Another Data Mapper

Another attempt to implement Data Mapper in ruby.

Built with 2 goals in mind:

* to get familiar with common pitfalls in implementing Data Mapper
* to make a tool that can be useful now and has the potential to be able
to serve as a replacement for ActiveRecord eventually

## Installation

```ruby
# Gemfile
gem 'yadm'
```

``` sh
$ bundle
```

## Usage

YADM consists of several components:

* entities
* repositories
* identity map
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

_You don't need to specify the `id` attribute, it comes by default._

### Repositories

A repository is a module representing a collection of entities. It can fetch
the objects from the data store and persist the changes back. Here you can
define complex criteria for querying the data source.

A repository is created as a module that includes `YADM::Repository`
and specifies it's entity:

``` ruby
module People
  include YADM::Repository
  entity Person
  
  criteria :kids do
    with { age < 12 }
  end
  
  criteria :older_than do |min_age|
    with { age > min_age }
  end
  
  criteria :in_alphabetical_order do
    ascending_by { last_name }.ascending_by { first_name }
  end
  
  criteria :oldest do |count|
    descending_by { age }.first(count)
  end
end
```

### Identity map

The identity map is a cache for data.

Most data requests first look it up in the identity map. If it's there
it is returned without accessing the data source; otherwise it is pulled from
the data source, put into the map for subsequent queries and then returned.

_Currently the identity map doesn't handle any complex queries - only `.find`
calls are cached._

### Data sources

Data sources encapsulate the ability to read the data and write it back.
They are defined by adapters for different data storage solutions;
YADM ships with the following adapters:

* `memory` (useful for testing)
* `sqlite` (requires `sequel` and `sqlite3` gems)
* `mysql` (requires `sequel` and `mysql2` gems)
* `postgresql` (requires `sequel` and `pg` gems)

Adapters are not required by default (because of their dependencies)
so you should manually require each adapter you need manually.

You can register a data source with some unique identifier to use it later on:

``` ruby
require 'yadm/adapters/memory'
require 'yadm/adapters/postgresql'

YADM.setup do
  data_source :memory_store, adapter: :memory
  data_source :pg_store, adapter: :postgresql, database: 'yadm', user: 'yadm', password: 'yadm'
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

_The data source is divided into separate collections represented by tables
in a database (and by plain ruby hashes in the memory adapter)._

### Creating a new record

A new record can be created by building a new entity object and passing it
to it's repository `.persist` method. Entity gets an `id` after being saved.

``` ruby
john = Person.new(
  first_name: 'John',
  last_name:  'Smith',
  email:      'john@smiths.com',
  password:   'secret',
  age:        28
)
john.id # => nil

People.persist(john)
jonh.id # => 1
```

### Getting a record by id

Dead simple:

``` ruby
People.find(1) # => #<Person:0x007ffdeab7f8c8 ...>
```

### Updating a record

The `.persist` method is able to distinguish between a new entity and
an already saved one; in the latter case it updates the respective record
in the data source.

``` ruby
john.password = 'f1E2m0CdP'
People.persist(john)
```

### Deleting a record

Deleting a record is as simple as passing the respective entity to
`.delete` method.

``` ruby
People.delete(john)
```

### Using complex queries

The `criteria` method in the repository DSL (mentioned earlier)
allows to create query criteria such as query conditions, order and limit.
Criteria's name serves as a name for the repository method
that applies the criteria.

``` ruby
People.kids # => #<People::Query:0x007f940b104db0 ...>
```

The query object is enumerable - you can call any `Enumerable` methods such as
`each` or `map` on it. Data is fetched lazily: the data source will be asked
for data only when it is needed:

``` ruby
People.kids.map(&:first_name) # => ['John']
```

This laziness allows to chain criteria methods together effectively merging
them in one big criteria:

``` ruby
People.older_than(30).in_alphabetical_order # => #<People::Query:0x007f940a9abed8 ...>
```

When you just want to get all the records without filtering/ordering them
you can call `.to_a` on the repository:

``` ruby
People.to_a # => [#<Person:0x007f940ae39360 ...>, #<Person:0x007f940acfa580 ...>]
```

_You can call enumerable methods on the repository as well - this allows
to traverse all records in the collection._

### Migrations

Working with a relational database requires changing it's schema often;
this is what migrations are for. YADM provides a very simple interface for
defining [sequel migrations](http://sequel.jeremyevans.net/rdoc/files/doc/schema_modification_rdoc.html):

``` ruby
YADM.migrate :store do |db|
  db.create_table :posts do
    primary_key :id
    
    String  :title
    String  :author
    Integer :comments
    Time    :created_at
  end
end
```

_You must define the respective data source before trying to migrate it._

## Roadmap

* SQL joins
* associations
* more adapters

## Acknowledgements

This project is heavily inspired by [lotus/model](https://github.com/lotus/model)
and [ROM](http://rom-rb.org).

## Examples

There are a couple examples in the `examples/` directory.

## Contributing

1. Fork it (https://github.com/7even/yadm/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
