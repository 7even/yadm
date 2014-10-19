module YADM
  module Adapters
    class MemoryAdapter
      attr_reader :collections
      private :collections
      
      def initialize(connection_params = {})
        # Memory adapter doesn't need any connection.
        @collections = Hash.new do |hash, collection_name|
          hash[collection_name] = Collection.new
        end
      end
      
      def get(collection_name, id)
        collections[collection_name].get(id)
      end
      
      def add(collection_name, object)
        collections[collection_name].add(object)
      end
      
      def change(collection_name, id, new_attributes)
        collections[collection_name].change(id, new_attributes)
      end
      
      def remove(collection_name, id)
        collections[collection_name].remove(id)
      end
      
      def count(collection_name)
        collections[collection_name].count
      end
      
      class Collection
        attr_reader :objects
        private :objects
        
        def initialize
          @objects = {}
        end
        
        def get(id)
          objects.fetch(id)
        end
        
        def add(object)
          next_id.tap do |new_id|
            objects[new_id] = object.merge(id: new_id)
          end
        end
        
        def change(id, new_attributes)
          objects[id].update(new_attributes)
        end
        
        def remove(id)
          objects.delete(id)
        end
        
        def count
          objects.count
        end
        
      private
        def next_id
          id_sequence.next
        end
        
        def id_sequence
          @sequence ||= Enumerator.new do |yielder|
            id = 0
            loop do
              id += 1
              yielder.yield id
            end
          end
        end
      end
    end
  end
end
