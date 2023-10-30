module Objects
  class MObject
    def type_desc
      self.class.to_s
    end

    def if_not_error(&)
      case self
      when MError
        self
      else
        yield self
      end
    end

    def truthy?
      case self
      when MBoolean
        value
      when MNull
        false
      else
        true
      end
    end

    def error?
      is_a?(MError)
    end
  end


  class MValue < MObject
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def inspect
      @value.to_s
    end

    def hash_type; end

    def hash_key; end
  end

  class MInteger < MValue
    def -@
      MInteger.new(-@value)
    end

    def +(other)
      MInteger.new(@value + other.value)
    end

    def -(other)
      MInteger.new(@value - other.value)
    end

    def *(other)
      MInteger.new(@value * other.value)
    end

    def /(other)
      MInteger.new((@value / other.value))
    end

    def <(other)
      @value < other.value
    end

    def >(other)
      @value > other.value
    end

    def ==(other)
      @value == other.value
    end

    def hash_type
      HashType::INTEGER
    end

    def hash_key
      HashKey.new(hash_type, @value)
    end
  end

  class MReturnValue < MObject
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def inspect
      @value.inspect
    end
  end

  class MError < MObject
    attr_reader :message

    def initialize(message)
      @message = message
    end

    def inspect
      "ERROR: #{@message}"
    end

    def to_s
      "MError(message=#{@message})"
    end
  end

  class MBoolean < MValue
    def ==(other)
      @value == other.value
    end

    def hash_type
      HashType::BOOLEAN
    end

    def hash_key
      HashKey.new(hash_type, (@value ? 1 : 0))
    end
  end

  class MNull < MObject
    def to_s
      "null"
    end
  end

  class MFunction < MObject
    attr_reader :environment, :body, :parameters

    def initialize(parameters, body, environment)
      @parameters = parameters
      @body = body
      @environment = environment
    end

    def inspect
      parameters = ""
      parameters = @parameters.map(&:to_s).join(", ") unless @parameters.nil?
      "fn(#{parameters}) {\n\t#{body}\n}"
    end
  end

  def self.arg_size_check(expected_size, args, &)
    length = args.size
    if length == expected_size
      yield args
    else
      MError.new("wrong number of arguments. got=#{length}, want=#{expected_size}")
    end
  end

  def self.rest(args)
    arg_size_check(1, args) do |arguments|
      array_check(REST_NAME, arguments) do |array, length|
        if length.positive?
          array.elements.delete_at(0)
          MArray.new(array.elements)
        end
      end
    end
  end

  M_NULL = MNull.new

end
