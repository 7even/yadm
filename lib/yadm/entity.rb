module YADM
  module Entity
    def initialize(new_attributes)
      self.class.attributes.each do |attr_name|
        attributes[attr_name] = fetch(new_attributes, attr_name)
      end
    end
    
    def attributes
      @attributes ||= {}
    end
    
  private
    def fetch(hash, key)
      hash[key] || hash[key.to_s]
    end
    
    class << self
      def included(including_class)
        including_class.extend(DSL)
        including_class.attribute(:id, readonly: true)
      end
    end
    
    module DSL
      def attribute(attr_name, readonly: false)
        attr_name = attr_name.to_sym
        
        attributes.add(attr_name)
        
        define_method(attr_name) do
          attributes[attr_name]
        end
        
        define_method("#{attr_name}=") do |new_value|
          attributes[attr_name] = new_value
        end unless readonly
      end
      
      def attributes(*attr_names)
        if attr_names.empty?
          @attributes ||= Set.new
        else
          attr_names.each do |attr_name|
            attribute(attr_name)
          end
        end
      end
    end
  end
end
