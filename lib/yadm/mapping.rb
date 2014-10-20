require 'yadm/mapping/attribute'

module YADM
  class Mapping
    def initialize(&block)
      instance_eval(&block) unless block.nil?
    end
    
    def get(id)
      attribute_values = data_source.get(collection, id)
      
      attributes.each_with_object(Hash.new) do |(attr_name, attribute), hash|
        raw_value = attribute_values[attr_name]
        hash[attr_name] = attribute.coerce(raw_value)
      end
    end
    
    def add(attributes)
      data_source.add(collection, attributes)
    end
    
    def change(id, attributes)
      data_source.change(collection, id, attributes)
    end
    
    def remove(id)
      data_source.remove(collection, id)
    end
    
    def count
      data_source.count(collection)
    end
    
    module DSL
      def data_source(data_source_identifier = nil)
        if data_source_identifier.nil?
          @data_source
        else
          @data_source = YADM.data_sources.fetch(data_source_identifier)
        end
      end
      
      def collection(new_collection = nil)
        if new_collection.nil?
          @collection
        else
          @collection = new_collection
        end
      end
      
      def attribute(name, type)
        attributes[name] = Attribute.new(type)
      end
      
      def attributes
        @attributes ||= {}
      end
    end
    
    include DSL
  end
end
