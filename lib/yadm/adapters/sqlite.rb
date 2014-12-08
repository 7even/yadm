require 'yadm/adapters/common_sql'
require 'sqlite3'

module YADM
  module Adapters
    class Sqlite
      include Base
      include CommonSQL
      
      register :sqlite
      
      def initialize(connection_parameters = {})
        @connection = Sequel.connect(adapter: :sqlite, **connection_parameters)
      end
    end
  end
end
