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
  end
end
