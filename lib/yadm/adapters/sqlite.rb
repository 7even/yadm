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
    end
  end
end
