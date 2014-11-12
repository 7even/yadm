module YADM
  class IdentityMap
    attr_reader :data_source, :map
    private :data_source, :map
    
    def initialize(data_source)
      @data_source = data_source
      
      @map = Hash.new do |map, collection|
        map[collection] = {}
      end
    end
    
    def get(collection, id)
      map[collection][id] ||= data_source.get(collection, id).dup
    end
    
    def add(collection, attributes)
      data_source.add(collection, attributes).tap do |id|
        map[collection][id] = attributes.merge(id: id)
      end
    end
    
    def change(collection, id, new_attributes)
      data_source.change(collection, id, new_attributes)
      
      if attributes = map[collection][id]
        attributes.update(new_attributes)
      else
        map[collection][id] = new_attributes.merge(id: id)
      end
    end
    
    def remove(collection, id)
      data_source.remove(collection, id)
      map[collection].delete(id)
    end
    
    def count(collection)
      data_source.count(collection)
    end
    
    def send_query(query)
      data_source.send_query(query)
    end
  end
end
