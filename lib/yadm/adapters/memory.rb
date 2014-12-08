module YADM
  module Adapters
    class Memory
      include Base
      
      register :memory
      
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
      
      def add(collection_name, record)
        collections[collection_name].add(record)
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
      
      def migrate(block)
        # do nothing here (memory adapter doesn't need migrations)
      end
      
      class Collection
        attr_reader :records
        private :records
        
        def initialize
          @records = {}
        end
        
        def get(id)
          records.fetch(id)
        end
        
        def add(record)
          next_id.tap do |new_id|
            records[new_id] = record.merge(id: new_id)
          end
        end
        
        def change(id, new_attributes)
          records[id].update(new_attributes)
        end
        
        def remove(id)
          records.delete(id)
        end
        
        def count
          records.count
        end
        
        def send_query(query)
          result = filter(all, query.criteria.condition, query.arguments)
          result = order(result, query.criteria.order, query.arguments)
          result = limit(result, query.criteria.limit, query.arguments)
        end
        
        def all
          records.values.dup
        end
        
        def filter(dataset, condition, arguments)
          if condition.nil?
            dataset
          else
            dataset.select { |record| matches?(record, condition.expression, arguments) }
          end
        end
        
        def order(dataset, order, arguments)
          if order.nil?
            dataset
          else
            dataset.sort { |*records| compare(records, order.clauses, arguments) }
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
        
        def matches?(record, expression, arguments)
          !!record_eval(record, expression, arguments)
        end
        
        def compare(records, clauses, arguments)
          clauses.inject(0) do |comparison, clause|
            return comparison unless comparison.zero?
            
            values = records.map do |record|
              record_eval(record, clause.expression, arguments)
            end
            
            if clause.asc?
              values.first <=> values.last
            else
              values.last <=> values.first
            end
          end
        end
        
        def take(records, limit, arguments)
          number = if limit.is_a?(Criteria::Argument)
            limit.fetch_from(arguments)
          else
            limit
          end
          
          records.take(number)
        end
        
        def record_eval(record, node, arguments)
          case node
          when Criteria::Expression
            receiver  = record_eval(record, node.receiver, arguments)
            arguments = node.arguments.map { |arg| record_eval(record, arg, arguments) }
            
            receiver.send(node.method_name, *arguments)
          when Criteria::Attribute
            record.fetch(node.name) do
              raise ArgumentError, "#{node.name.inspect} attribute not found."
            end
          when Criteria::Argument
            node.fetch_from(arguments)
          else
            node
          end
        end
      end
    end
  end
end
