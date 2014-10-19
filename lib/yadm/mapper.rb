module YADM
  class Mapper
    def repository(repository_class, &block)
      mappings[repository_class] = Mapping.new(&block)
    end
    
    def mapping_for(repository)
      mappings.fetch(repository)
    end
    
  private
    def mappings
      @mappings ||= {}
    end
  end
end
