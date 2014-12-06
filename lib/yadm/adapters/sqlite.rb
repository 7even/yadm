require 'sequel'
require 'sqlite3'

module YADM
  module Adapters
    class Sqlite
      attr_reader :connection
      private :connection
      
      def initialize(connection_parameters = {})
        @connection = Sequel.connect(adapter: :sqlite, **connection_parameters)
      end
      
      def get(table_name, id)
        connection[table_name][id: id]
      end
      
      def add(table_name, object)
        connection[table_name].insert(object)
      end
      
      def change(table_name, id, new_attributes)
        connection[table_name].where(id: id).update(new_attributes)
      end
      
      def remove(table_name, id)
        connection[table_name].where(id: id).delete
      end
      
      def count(table_name)
        connection[table_name].count
      end
      
      def send_query(table_name, query)
        result = filter(from(table_name), query.criteria.condition, query.arguments)
      end
      
      def from(table_name)
        connection[table_name]
      end
      
      def filter(dataset, condition, arguments)
        if condition.nil?
          dataset
        else
          sequel_expression = sequelize(condition.expression, arguments)
          dataset.where(sequel_expression)
        end
      end
      
    private
      def sequelize(node, arguments)
        self.class.sequelize(node, arguments)
      end
      
      class << self
        def sequelize(node, arguments)
          case node
          when Criteria::Expression
            operator  = sequelize_operator(node.method_name)
            receiver  = sequelize(node.receiver, arguments)
            arguments = node.arguments.map { |arg| sequelize(arg, arguments) }
            
            Sequel::SQL::ComplexExpression.new(operator, receiver, *arguments)
          when Criteria::Expression::Attribute
            Sequel::SQL::Identifier.new(node.name)
          when Criteria::Expression::Argument
            node.fetch_from(arguments)
          else
            node
          end
        end
        
      private
        def sequelize_operator(operator)
          case operator
          when :== then :'='
          when :&  then :AND
          when :|  then :OR
          else operator
          end
        end
      end
    end
  end
end
