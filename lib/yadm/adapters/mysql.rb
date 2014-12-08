require 'yadm/adapters/common_sql'
require 'mysql2'

module YADM
  module Adapters
    class MySQL
      include Base
      include CommonSQL
      
      register :mysql
      
      def initialize(connection_parameters = {})
        @connection = Sequel.connect(adapter: :mysql2, **connection_parameters)
      end
    end
  end
end
