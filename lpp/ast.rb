module AST
  class ASTNode
    def token_literal
      raise NotImplementedError
    end
  
    def to_s
      raise NotImplementedError
    end
  end
  
  class Statement < ASTNode
    attr_reader :token
  
    def initialize(token)
      @token = token
    end
  
    def token_literal
      @token.literal
    end
  end

  class Expression
    attr_reader :token
  
    def initialize(token)
      @token = token
    end
  
    def token_literal
      token.literal
    end
  end
  
  class Program
    attr_reader :statements
  
    def initialize(statements)
      @statements = statements
    end
  
    def token_literal
      return '' if statements.empty?
  
      statements.first.token_literal
    end
  
    def to_s
      statements.map(&:to_s).join('')
    end
  end
  
  class Identifier < Expression
    attr_reader :value
  
    def initialize(token, value)
      super(token)
      @value = value
    end
  
    def to_s
      value
    end
  end
  
  class LetStatement < Statement
    attr_reader :name, :value
  
    def initialize(token, name, value)
      super(token)
      @name = name
      @value = value
    end
  
    def to_s
      "#{token_literal} #{name} = #{value};"
    end
  end

  class ReturnStatement < Statement

    attr_reader :return_value

    def initialize(token, return_value = nil)
        super(token)
        @return_value = return_value
    end

    def to_s
        "#{token_literal} #{return_value};"
    end
  end

  class ExpressionStatement < Statement

    attr_reader :expression

    def initialize(token, expression = nil)
        super(token)
        @expression = expression
    end

    def to_s
        "#{expression}"
    end

  end

  class Integer < Expression

    attr_reader :value

    def initialize(token, value = nil)
        super(token)
        @value = value
    end

    def to_s
        "#{value}"
    end
  end

  class Prefix < Expression

    attr_reader :operator, :right

    def initialize(token, operator, right = nil)
        super(token)
        @operator = operator
        @right = right
    end

    def to_s
        "(#{operator}#{right})"
    end

  end

  class Infix < Expression

    attr_reader :left, :operator, :right

    def initialize(token, left, operator, right = nil)
        super(token)
        @left = left
        @operator = operator
        @right = right
    end

    def to_s
        "(#{left} #{operator} #{right})"
    end

  end

  class Boolean < Expression
    attr_reader :value
  
    def initialize(token:, value: nil)
      super(token: token)
      @value = value
    end
  
    def to_s
      token_literal
    end
  end
  
  class Block < Statement
    attr_reader :statements
  
    def initialize(token:, statements:)
      super(token: token)
      @statements = statements
    end
  
    def to_s
      statements.map(&:to_s).join
    end
  end
  
  class If < Expression
    attr_reader :condition, :consequence, :alternative
  
    def initialize(token:, condition: nil, consequence: nil, alternative: nil)
      super(token: token)
      @condition = condition
      @consequence = consequence
      @alternative = alternative
    end
  
    def to_s
      out = "si #{condition} #{consequence}"
      out += "si_no #{alternative}" if alternative
  
      out
    end
  end
  
  class Function < Expression
    attr_reader :parameters, :body
  
    def initialize(token:, parameters: [], body: nil)
      super(token: token)
      @parameters = parameters
      @body = body
    end
  
    def to_s
      params = parameters.map(&:to_s).join(', ')
  
      "#{token_literal}(#{params}) #{body}"
    end
  end
  
  class Call < Expression
    attr_reader :function, :arguments
  
    def initialize(token:, function:, arguments: nil)
      super(token: token)
      @function = function
      @arguments = arguments
    end
  
    def to_s
      args = arguments.map(&:to_s).join(', ')
  
      "#{function}(#{args})"
    end
  end
end