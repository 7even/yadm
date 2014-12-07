module SequelHelpers
  def setup_table
    connection.create_table :posts do
      primary_key :id
      
      String   :title
      Integer  :comments_count
      Datetime :created_at
    end
    
    [
      ['First',  7,  now - 10],
      ['Second', 10, now - 20],
      ['Third',  4,  now - 10],
      ['Fourth', 13, now]
    ].each do |title, comments_count, created_at|
      subject.add(
        :posts,
        title:          title,
        comments_count: comments_count,
        created_at:     created_at
      )
    end
  end
end
