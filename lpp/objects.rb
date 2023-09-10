class ObjectType
    BOOLEAN=:boolean
    INTEGER=:integer
    NULL=:null
    FLOAT=:float
    STRING=:string
end

class Object
    def type()
        raise NotImplementedError.new("Abstract method type not implemented")
    end

    def inspect()
        raise NotImplementedError.new("Abstract method inspect not implemented")
    end
end

class Integer < Object
    def initialize(value)
        @value=value
    end
    
    def type()
        return ObjectType::INTEGER
    end
    
    def inspect()
        return @value.to_s
    end
end

class Boolean < Object
    def initialize(value)
        @value=value
    end
    
    def type()
        return ObjectType::BOOLEAN
    end
    
    def inspect()
        return @value.to_s
    end
end

class Null < Object
    
    
    def type()
        return ObjectType::NULL
    end
    
    def inspect()
        return 'nulo'
    end
    
end