
require_relative 'tokens'

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
  
  class Expression < ASTNode
    attr_reader :token
  
    def initialize(token)
      @token = token
    end
  
    def token_literal
      @token.literal
    end
  end


  class Program

    def initialize(statements)
      @statements = statements
    end
  
    def token_literal
      return @statements[0]
    end
  
    def to_s
      return @statements
    end
  end

  class Identifier
    attr_reader :token, :value
    def initialize(token, value)
      @token = token
      @value = value
    end
    def to_s
      @value
    end
  end
  
  class LetStatement
    attr_reader :token, :name, :value
    def initialize(token, name = nil, value = nil)
      @token = token
      @name = name
      @value = value
    end
    def to_s
      "#{token.literal} #{name} = #{value};"
    end
  end
  
  class ReturnStatement < Statement
    attr_accessor :return_value
    def initialize token, return_value=nil
      super(token)
      @return_value = return_value
    end
    def to_s
      "#{token_literal} #{return_value.to_s};"
    end
  end
  


  class ExpressionStatement < Statement
    attr_accessor :expression
  
    def initialize(token, expression = nil)
      super(token)
      @expression = expression
    end
  
    def to_s
      @expression.to_s
    end
  end
  
  class Integer < Expression
    attr_accessor :value
  
    def initialize(token, value = nil)
      super(token)
      @value = value
    end
  
    def to_s
      @value.to_s
    end
  end

  class Prefix < Expression

    def initialize(token, operator, right = nil)
        super(token)
        @operator = operator
        @right = right
    end

    def to_s
        "(#{@operator}#{@right})"
    end

end


class Infix < Expression

    def initialize(token, left, operator, right = nil)
        super(token)
        @left = left
        @operator = operator
        @right = right
    end

    def to_s
        "(#{@left} #{@operator} #{@right})"
    end

end


class Boolean < Expression

    def initialize(token, value = nil)
        super(token)
        @value = value
    end

    def to_s
        token_literal()
    end

end


class Block < Statement

    def initialize(token, statements)
        super(token)
        @statements = statements
    end

    def to_s
        out = @statements.map { |statement| statement.to_s }.join('')

        out
    end

end

class If < Expression

    def initialize(token, condition = nil, consequence = nil, alternative = nil)
        super(token)
        @condition = condition
        @consequence = consequence
        @alternative = alternative
    end

    def to_s
        out = "si #{str(@condition)} #{str(@consequence)}"

        if @alternative
            out += "si_no #{str(@alternative)}"
        end

        out
    end

end


class Function < Expression

    def initialize(token, parameters = [], body = nil)
        super(token)
        @parameters = parameters
        @body = body
    end

    def to_s
        param_list = @parameters.map { |parameter| parameter.to_s }

        params = param_list.join(', ')

        "#{token_literal()}(#{params}) #{str(@body)}"
    end

end


class Call < Expression

    def initialize(token, function, arguments = nil)
        super(token)
        @function = function
        @arguments = arguments
    end

    def to_s
        arg_list = @arguments.map { |argument| argument.to_s }
        args = arg_list.join(', ')

        "#{str(@function)}(#{args})"
    end

end



