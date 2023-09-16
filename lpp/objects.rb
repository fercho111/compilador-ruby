module OBJECTS
  module ObjectType
    BOOLEAN = :BOOLEAN
    ERROR = :ERROR
    INTEGER = :INTEGER
    NULL = :NULL
    RETURN = :RETURN
  end

  class Object
    def type
      raise NotImplementedError, "Subclasses must implement 'type'"
    end

    def inspect
      raise NotImplementedError, "Subclasses must implement 'inspect'"
    end
  end

  class Integer < Object
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def type
      ObjectType::INTEGER
    end

    def inspect
      @value.to_s
    end
  end

  class Boolean < Object
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def type
      ObjectType::BOOLEAN
    end

    def inspect
      @value ? 'verdadero' : 'falso'
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

  class Return < Object
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def type
      ObjectType::RETURN
    end

    def inspect
      @value.inspect
    end
  end

  class Error < Object
    attr_reader :message

    def initialize(message)
      @message = message
    end

    def type
      ObjectType::ERROR
    end

    def inspect
      "Error: #{@message}"
    end
  end

  class Environment
    def initialize
      @store = {}
    end

    def [](key)
      @store[key]
    end

    def []=(key, value)
      @store[key] = value
    end

    def delete(key)
      @store.delete(key)
    end
  end
end