module YADM
  module Adapters
    class Memory
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
      
      def send_query(collection_name, query)
        collections[collection_name].send_query(query)
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
        
        def send_query(query)
          result = filter(all, query.criteria.condition, query.arguments)
          result = order(result, query.criteria.order, query.arguments)
          result = limit(result, query.criteria.limit, query.arguments)
        end
        
        def all
          objects.values.dup
        end
        
        def filter(dataset, condition, arguments)
          if condition.nil?
            dataset
          else
            dataset.select { |object| matches?(object, condition.expression, arguments) }
          end
        end
        
        def order(dataset, order, arguments)
          if order.nil?
            dataset
          else
            dataset.sort { |*objects| compare(objects, order.clauses, arguments) }
          end
        end
        
        def limit(dataset, limit, arguments)
          if limit.nil? || limit.limit.nil?
            dataset
          else
            take(dataset, limit.limit, arguments)
          end
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
        
        def matches?(object, expression, arguments)
          !!object_eval(object, expression, arguments)
        end
        
        def compare(objects, clauses, arguments)
          clauses.inject(0) do |comparison, clause|
            return comparison unless comparison.zero?
            
            values = objects.map do |object|
              object_eval(object, clause.expression, arguments)
            end
            
            if clause.asc?
              values.first <=> values.last
            else
              values.last <=> values.first
            end
          end
        end
        
        def take(objects, limit, arguments)
          number = if limit.is_a?(YADM::Criteria::Expression::Argument)
            extract_argument(arguments, limit)
          else
            limit
          end
          
          objects.take(number)
        end
        
        def object_eval(object, node, arguments)
          case node
          when Criteria::Expression
            receiver  = object_eval(object, node.receiver, arguments)
            arguments = node.arguments.map { |arg| object_eval(object, arg, arguments) }
            
            receiver.send(node.method_name, *arguments)
          when Criteria::Expression::Attribute
            object[node.name]
          when Criteria::Expression::Argument
            extract_argument(arguments, node)
          else
            node
          end
        end
        
        def extract_argument(arguments, node)
          arguments[node.group][node.index]
        end
      end
    end
  end
end
