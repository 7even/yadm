# use with `pry -r ./examples/migration.rb`
$LOAD_PATH << File.expand_path('../../lib')
require 'yadm'
require 'yadm/adapters/sqlite'

class Post
  include YADM::Entity
  attributes :title, :author, :comments, :created_at
end

module Posts
  include YADM::Repository
  entity Post
  
  criteria :recent do
    ascending_by { created_at }.first(20)
  end
  
  criteria :created_by do |given_author|
    with { author == given_author }
  end
end

YADM.setup do
  data_source :store, adapter: :sqlite
  
  map do
    repository Posts do
      data_source :store
      collection  :posts
      
      attribute :id,         Integer
      attribute :title,      String
      attribute :author,     String
      attribute :comments,   Integer
      attribute :created_at, Time
    end
  end
end

YADM.migrate :store do |db|
  db.create_table :posts do
    primary_key :id
    
    String  :title
    String  :author
    Integer :comments
    Time    :created_at
  end
end

[
  Post.new(
    title:      'Hello World!',
    author:     '7even',
    comments:   7,
    created_at: Time.now - 3600
  ),
  Post.new(
    title:      'Goodbye cruel world.',
    author:     'foxweb',
    comments:   5,
    created_at: Time.now - 1800
  )
].each { |post| Posts.persist(post) }
