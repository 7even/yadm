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
        result = filter(connection[table_name], query.criteria.condition)
      end
      
      def filter(dataset, condition)
        if condition.nil?
          dataset
        else
          sequel_expression = sequelize(condition.expression)
          dataset.where(sequel_expression)
        end
      end
      
    private
      def sequelize(node)
        case node
        when Criteria::Expression
          receiver  = sequelize(node.receiver)
          arguments = node.arguments.map { |arg| sequelize(arg) }
          
          Sequel::SQL::ComplexExpression.new(node.method_name, receiver, *arguments)
        when Criteria::Expression::Attribute
          Sequel::SQL::Identifier.new(node.name)
        else
          node
        end
      end
    end
  end
end
