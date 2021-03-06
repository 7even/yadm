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
        Class.new(YADM::Query) do
          define_method :repository do
            repository
          end
        end
      end
    end
    
    module ClassMethods
      include Enumerable
      
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
      
      def each(&block)
        default_query.each(&block)
      end
      
      def count
        mapping.count
      end
      
      def send_query(query)
        mapping.send_query(query).map do |attributes|
          wrap_object(attributes)
        end
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
      def criteria(name, &block)
        criteria = CriteriaParser.parse(block, name)
        
        query_class.class_eval do
          define_method(name) do |*args|
            merge(criteria, name => args)
          end
        end
        
        define_singleton_method(name) do |*args|
          default_query.public_send(name, *args)
        end
      end
      
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
