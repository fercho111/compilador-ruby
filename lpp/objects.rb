require 'enum'

class ObjectType
    include Enum

    new :BOOLEAN
    new :INTEGER
    new :NULL
    new :FLOAT
    new :STRING
end

class Object
    def type
    end
    
    def inspect
    end
  end
  
  class Integer < Object
    attr_accessor :value
    def initialize(value)
      @value=value
    end
    
    def type
      ObjectType::INTEGER
    end
    
    def inspect
      @value.to_s
    end
  end
  
  class Boolean < Object
    attr_accessor :value
    def initialize(value)
      @value=value
    end
    
    def type
      ObjectType::BOOLEAN
    end
    
    def inspect
      @value.to_s
    end
  end
  
  class Null < Object
    def type
      ObjectType::NULL
    end
    
    def inspect
      'nulo'
    end
  end