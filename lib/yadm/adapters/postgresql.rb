require 'yadm/adapters/common_sql'
require 'pg'

module YADM
  module Adapters
    class PostgreSQL
      include Base
      include CommonSQL
      
      register :postgresql
      
      def initialize(connection_parameters = {})
        @connection = Sequel.connect(adapter: :postgres, **connection_parameters)
      end
    end
  end
end
