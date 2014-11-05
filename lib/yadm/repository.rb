module YADM
  module Repository
    class << self
      def included(including_class)
        including_class.const_set(:Query, query_class_for(including_class))
        
        including_class.extend(ClassMethods)
        including_class.extend(DSL)
      end
      
    private
      def query_class_for(repository)
        Class.new do
          define_singleton_method :repository do
            repository
          end
        end
      end
    end
    
    module ClassMethods
      def find(id)
        wrap_object(mapping.get(id))
      end
      
      def persist(entity)
        if entity.id.nil?
          entity.id = mapping.add(entity.attributes)
        else
          new_attributes = entity.attributes
          mapping.change(new_attributes.delete(:id), new_attributes)
        end
      end
      
      def delete(entity)
        mapping.remove(entity.id)
      end
      
      def count
        mapping.count
      end
      
      def default_query
        query_class.new
      end
      
    private
      def wrap_object(attributes)
        entity_class.new(attributes)
      end
      
      def mapping
        YADM.mapper.mapping_for(self)
      end
      
      def query_class
        const_get(:Query)
      end
    end
    
    module DSL
      
    private
      def entity(entity_class)
        @entity_class = entity_class
      end
      
      def entity_class
        if @entity_class.nil?
          raise ArgumentError, "Entity is not declared for repository #{self.name}"
        else
          @entity_class
        end
      end
    end
  end
end
