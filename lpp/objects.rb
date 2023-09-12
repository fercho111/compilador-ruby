module Abc
    def type
      raise "AbstractMethodError"
    end
    
    def inspect
      raise "AbstractMethodError"
    end
  end
  
  class ObjectType
    BOOLEAN='BOOLEAN'
    INTEGER='INTEGER'
    NULL='NULL'
    FLOAT='FLOAT'
    STRING='STRING'
  end
  
  class Object
    include Abc
    
    def type
      raise "AbstractMethodError"
    end
    
    def inspect
      raise "AbstractMethodError"
    end
  end
  
  class Integer < Object
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