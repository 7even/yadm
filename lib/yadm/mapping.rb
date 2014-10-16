require 'yadm/mapping/attribute'

module YADM
  class Mapping
    attr_reader :identity_map, :collection, :attributes
    
    def initialize(identity_map, collection, attributes: [])
      @identity_map = identity_map
      @collection   = collection
      @attributes   = attributes
    end
    
    def get(id)
      attribute_values = identity_map.get(collection, id)
      
      attributes.each_with_object(Hash.new) do |(attr_name, attribute), hash|
        raw_value = attribute_values[attr_name]
        hash[attr_name] = attribute.coerce(raw_value)
      end
    end
  end
end
