from abc import (
    ABC,
    abstractmethod,
)
from typing import (
    List,
    Optional,
)

from elcompifiles.tokens import Token


class ASTNode(ABC):

    @abstractmethod
    def token_literal(self) -> str:
        pass

    @abstractmethod
    def __str__(self) -> str:
        pass


class Statement(ASTNode):

    def __init__(self, token: Token) -> None:
        self.token = token

    def token_literal(self) -> str:
        return self.token.literal


class Expression(ASTNode):

    def __init__(self, token: Token) -> None:
        self.token = token

    def token_literal(self) -> str:
        return self.token.literal


class Program(ASTNode):

    def __init__(self, statements: List[Statement]) -> None:
        self.statements = statements

    def token_literal(self) -> str:
        if len(self.statements) > 0:
            return self.statements[0].token_literal()

        return ''

    def __str__(self) -> str:
        out: List[str] = []
        for statement in self.statements:
            out.append(str(statement))

        return ''.join(out)


class Identifier(Expression):

    def __init__(self,
                 token: Token,
                 value: str) -> None:
        super().__init__(token)
        self.value = value

    def __str__(self) -> str:
        return self.value
Translate code into


Ask Copilot
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


class Program < ASTNode
  attr_reader :statements

  def initialize(statements)
    @statements = statements
  end

  def token_literal
    return @statements[0].token_literal if @statements.length.positive?

    ''
  end

  def to_s
    @statements.map(&:to_s).join('')
  end
end


class Identifier < Expression
  attr_reader :value

  def initialize(token, value)
    super(token)
    @value = value
  end

  def to_s
    @value
  end
end

class LetStatement(Statement):

    def __init__(self,
                 token: Token,
                 name: Optional[Identifier] = None,
                 value: Optional[Expression] = None) -> None:
        super().__init__(token)
        self.name = name
        self.value = value

    def __str__(self) -> str:
        return f'{self.token_literal()} {str(self.name)} = {str(self.value)};'


class ReturnStatement(Statement):

    def __init__(self,
                 token: Token,
                 return_value: Optional[Expression] = None) -> None:
        super().__init__(token)
        self.return_value = return_value

    def __str__(self) -> str:
        return f'{self.token_literal()} {str(self.return_value)};'


class ExpressionStatement(Statement):

    def __init__(self,
                 token: Token,
                 expression: Optional[Expression] = None) -> None:
        super().__init__(token)
        self.expression = expression

    def __str__(self) -> str:
        return str(self.expression)


class Integer(Expression):

    def __init__(self,
                 token: Token,
                 value: Optional[int] = None) -> None:
        super().__init__(token)
        self.value = value

    def __str__(self) -> str:
        return str(self.value)

        class Prefix < Expression
            attr_accessor :operator, :right
            def initialize(token: nil, operator: nil, right: nil)
                super(token)
                @operator = operator
                @right = right
            end
        
            def to_s
                return "(@operator#{to_s(@right)})"
            end
        end
        
        class Infix < Expression
            attr_accessor :left, :operator, :right
            def initialize(token: nil, left: nil, operator: nil, right: nil)
                super(token)
                @left = left
                @operator = operator
                @right = right
            end
        
            def to_s
                return "(#{to_s(@left)} #{@operator} #{to_s(@right)})"
            end
        end
        
        class Boolean < Expression
            attr_accessor :value
            def initialize(token: nil, value: nil)
                super(token)
                @value = value
            end
        
            def to_s
                return @token.literal
            end
        end
        
        class Block < Statement
            attr_accessor :statements
            def initialize(token: nil, statements: nil)
                super(token)
                @statements = statements
            end
        
            def to_s
                out = @statements.map { |statement| to_s(statement) }.join
                return out
            end
        end
        
        class If < Expression
            attr_accessor :condition, :consequence, :alternative
            def initialize(token: nil, condition: nil, consequence: nil, alternative: nil)
                super(token)
                @condition = condition
                @consequence = consequence
                @alternative = alternative
            end
        
            def to_s
                out = "si #{to_s(@condition)} #{to_s(@consequence)}"
                if @alternative
                    out += "si_no #{to_s(@alternative)}"
                end
                return out
            end
        end
        
        class Function < Expression
            attr_accessor :parameters, :body
            def initialize(token: nil, parameters: nil, body: nil)
                super(token)
                @parameters = parameters
                @body = body
            end
        
            def to_s
                param_list = @parameters.map { |parameter| to_s(parameter) }
                params = param_list.join(', ')
                return "#{@token_literal}(#{params}) #{to_s(@body)}"
            end
        end
        
        class Call < Expression
            attr_accessor :function, :arguments
            def initialize(token: nil, function: nil, arguments: nil)
                super(token)
                @function = function
                @arguments = arguments
            end
        
            def to_s
                arg_list = @arguments.map { |argument| to_s(argument) }
                args = arg_list.join(', ')