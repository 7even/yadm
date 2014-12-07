require 'yadm/version'
require 'yadm/entity'
require 'yadm/adapters'
require 'yadm/identity_map'
require 'yadm/mapping'
require 'yadm/mapper'
require 'yadm/criteria'
require 'yadm/query'
require 'yadm/criteria_parser'
require 'yadm/repository'

module YADM
  class << self
    def setup(&block)
      instance_eval(&block) unless block.nil?
    end
    
    def data_source(name, adapter:, **connection_params)
      data_source = Adapters.fetch(adapter).new(connection_params)
      data_sources[name] = IdentityMap.new(data_source)
    end
    
    def map(&block)
      mapper.instance_eval(&block) unless block.nil?
    end
    
    def migrate(data_source_name, &block)
      data_sources.fetch(data_source_name).migrate(block)
    end
    
    def data_sources
      @data_sources ||= {}
    end
    
    def mapper
      @mapper ||= Mapper.new
    end
  end
end
