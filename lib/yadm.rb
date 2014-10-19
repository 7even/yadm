require 'yadm/version'
require 'yadm/entity'
require 'yadm/adapters'
require 'yadm/identity_map'
require 'yadm/mapping'
require 'yadm/repository'

module YADM
  class << self
    def setup(&block)
      instance_eval(&block) unless block.nil?
    end
    
    def data_source(name, adapter:, &block)
      data_source = Adapters.fetch(adapter).new(&block)
      data_sources[name] = IdentityMap.new(data_source)
    end
    
    def data_sources
      @data_sources ||= {}
    end
  end
end
