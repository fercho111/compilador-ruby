require_relative 'tokens'
require_relative 'ast'
require_relative 'lexer'

# definiendo esta vuelta de precedencias
module Precedence
  LOWEST = 1
  EQUALS = 2
  LESSGREATER = 3
  SUM = 4
  PRODUCT = 5
  PREFIX = 6
  CALL = 7
end

PRECEDENCES = {
  TokenType::EQ => Precedence::EQUALS,
  TokenType::NOT_EQ => Precedence::EQUALS,
  TokenType::LT => Precedence::LESSGREATER,
  TokenType::GT => Precedence::LESSGREATER,
  TokenType::PLUS => Precedence::SUM,
  TokenType::MINUS => Precedence::SUM,
  TokenType::DIVISION => Precedence::PRODUCT,
  TokenType::MULTIPLICATION => Precedence::PRODUCT,
  TokenType::LPAREN => Precedence::CALL
}

class Parser

  @property
  def errors
    @errors
  end

  def initialize(lexer)
    @lexer = lexer
    @current_token = nil
    @peek_token = nil
    @errors = []
  end

  def parse_program
    program = Program.new([])
    # raise 'Assertion error' if @current_token.nil?
    while @current_token.token_type != TokenType::EOF
      statement = parse_statement
      if statement != nil
        program.statements.push(statement)
      end
      advance_tokens
    end
    program
  end

  def parse
    parse_expression
  end

  private

  # Modificaciones en el Parser
  # Agrega reglas para expresiones con paréntesis

  def advance_tokens
    @current_token = @peek_token
    @peek_token = @lexer.next_token
  end

  def current_precedende
    # assert
    PRECEDENCES.fetch(@current_token.token_type, Precedence::LOWEST)
  end

  def expected_token(token_type)
    raise 'Assertion error' if @peek_token.nil?
    
    if @peek_token.token_type == token_type
        advance_tokens
        return true
    end

    expected_token_error(token_type)
    false
end

  def expected_token_error(token_type)
    # assert 
    error = 'Se esperaba que el siguiente token fuera #{token_type} pero se obtuvo #{@peek_token.token_type}'
    @errors.append(error)
  end

  def parse_block
    # assert
    block_statement = Block.new(@current_token, statements:[])
    advance_tokens
    while !(@current_token.token_type == TokenType::RBRACE) && !(@current_token.token_type == TokenType::EOF)
      statement = parse_statement
      if statement
        block_statement.statements.push(statement)
      end
      advance_tokens
    end
    return block_statement
  end

  def parse_boolean
    # assert
    return Boolean.new(@current_token, @current_token.token_type == TokenType::TRUE)
  end

  def parse_call(function)
    # assert
    call = Call.new(@current_token, function:function)
    call.arguments = parse_call_arguments
    return call
  end

  def parse_call_arguments
    arguments = []
    # assert
    if @peek_token.token_type == TokenType::RPAREN
      advance_tokens
      return arguments
    end
    advance_tokens
    if (expression = self._parse_expression(Precedence::LOWEST))
      arguments.push(expression)
    end

    while @peek_token.token_type == TokenType::COMMA
      advance_tokens
      advance_tokens
      
      if (expression = parse_expression(Precedence::LOWEST))
        arguments.push(expression)
      end
    end

    if !expected_token(TokenType::RPAREN)
      return nil
    end

    arguments

  end

  def parse_expression(precedence)
    raise 'current_token es nil' if @current_token.nil?
  
    begin
      prefix_parse_fn = @prefix_parse_fns[@current_token.token_type]
    rescue KeyError
      message = "No se encontró una función para analizar #{@current_token.literal}"
      @errors << message
      return nil
    end
  
    left_expression = prefix_parse_fn.call()
  
    raise 'peek_token es nil' if @peek_token.nil?
  
    while !(@peek_token.token_type == TokenType::SEMICOLON) && (precedence < peek_precedence())
      begin
        infix_parse_fn = @infix_parse_fns[@peek_token.token_type]
  
        advance_tokens()
  
        raise 'left_expression es nil' if left_expression.nil?
        left_expression = infix_parse_fn.call(left_expression)
      rescue KeyError
        return left_expression
      end
    end
  
    left_expression
  end
  
  
  def parse_expression_statement
    raise 'current_token es nil' if @current_token.nil?
    
    expression_statement = ExpressionStatement.new(token: @current_token)
    expression_statement.expression = parse_expression(Precedence::LOWEST)
    
    raise 'peek_token es nil' if @peek_token.nil?
    
    if @peek_token.token_type == TokenType::SEMICOLON
      advance_tokens()
    end
    
    expression_statement
  end

  def parse_grouped_expression
    advance_tokens()
    expression = parse_expression(Precedence::LOWEST)
    if !expected_token(TokenType::RPAREN)
      return nil
    end
    expression
  end

  def parse_function
    raise 'current_token es nil' if @current_token.nil?
    function = Function.new(token: @current_token)
    if !expected_token(TokenType::LPAREN)
      return nil
    end
    function.parameters = parse_function_parameters
    if !expected_token(TokenType::LBRACE)
      return nil
    end
    function.body = parse_block
    function
  end
  
   def parse_function_parameters
    parameters = []
    if @peek_token.token_type == TokenType::RPAREN
      advance_tokens()
      return parameters
    end
    advance_tokens()
    identifier = Identifier.new(token: @current_token, value: @current_token.literal)
    parameters.push(identifier)
    while @peek_token.token_type == TokenType::COMMA
      advance_tokens()
      advance_tokens()
      identifier = Identifier.new(token: @current_token, value: @current_token.literal)
      parameters.push(identifier)
    end
    if !expected_token(TokenType::RPAREN)
      return []
    end
    parameters
  end

  def parse_identifier
    raise 'current_token es nil' if @current_token.nil?
    Identifier.new(token: @current_token, value: @current_token.literal)
  end

  def parse_if
    raise 'current_token es nil' if @current_token.nil?
    if_expression = If.new(token: @current_token)
    if !expected_token(TokenType::LPAREN)
      return nil
    end
    advance_tokens()
    if_expression.condition = parse_expression(Precedence::LOWEST)
    if !expected_token(TokenType::RPAREN)
      return nil
    end
    if !expected_token(TokenType::LBRACE)
      return nil
    end
    if_expression.consequence = parse_block
    if @peek_token.token_type == TokenType::ELSE
      advance_tokens()
      if !expected_token(TokenType::LBRACE)
        return nil
      end
      if_expression.alternative = parse_block
    end
    if_expression
  end

  def parse_infix_expression(left)
    infix = Infix.new(token: @current_token, operator: @current_token.literal, left: left)
    precedence = current_precedence()
    advance_tokens()
    infix.right = parse_expression(precedence)
    infix
  end

  def parse_integer
    raise 'current_token es nil' if @current_token.nil?
    MyInteger.new(token: @current_token)
  end

  def parse_let_statement
    raise 'current_token es nil' if @current_token.nil?
    let_statement = LetStatement.new(token: @current_token)
    if !expected_token(TokenType::IDENT)
      return nil
    end
    let_statement.name = parse_identifier
    if !expected_token(TokenType::ASSIGN)
      return nil
    end
    advance_tokens()
    let_statement.value = parse_expression(Precedence::LOWEST)
    if @peek_token.token_type == TokenType::SEMICOLON
      advance_tokens()
    end
    let_statement
  end

  def parse_prefix_expression
    raise 'current_token es nil' if @current_token.nil?
    prefix_expression = Prefix.new(token: @current_token, operator: @current_token.literal)
    advance_tokens()
    prefix_expression.right = parse_expression(Precedence::PREFIX)
    prefix_expression
  end

  def parse_return_statement
    raise 'current_token es nil' if @current_token.nil?
    return_statement = ReturnStatement.new(token: @current_token)
    advance_tokens()
    return_statement.return_value = parse_expression(Precedence::LOWEST)
    if @peek_token.token_type == TokenType::SEMICOLON
      advance_tokens()
    end
    return_statement
  end

  def parse_statement
    raise 'current_token es nil' if @current_token.nil?
    if @current_token.token_type == TokenType::LET
      return parse_let_statement
    elsif @current_token.token_type == TokenType::RETURN
      return parse_return_statement
    else
      return parse_expression_statement
    end
  end

  def peek_precedence
    raise 'peek_token es nil' if @peek_token.nil?
    
    begin
      return PRECEDENCES[@peek_token.token_type]
    rescue KeyError
      return Precedence::LOWEST
    end
  end
  
  def register_infix_fns
    {
      TokenType::PLUS => method(:parse_infix_expression),
      TokenType::MINUS => method(:parse_infix_expression),
      TokenType::DIVISION => method(:parse_infix_expression),
      TokenType::MULTIPLICATION => method(:parse_infix_expression),
      TokenType::EQ => method(:parse_infix_expression),
      TokenType::NOT_EQ => method(:parse_infix_expression),
      TokenType::LT => method(:parse_infix_expression),
      TokenType::GT => method(:parse_infix_expression),
      TokenType::LPAREN => method(:parse_call)
    }
  end

  def register_prefix_fns
    {
      TokenType::IDENT => method(:parse_identifier),
      TokenType::INT => method(:parse_integer),
      TokenType::BANG => method(:parse_prefix_expression),
      TokenType::MINUS => method(:parse_prefix_expression),
      TokenType::TRUE => method(:parse_boolean),
      TokenType::FALSE => method(:parse_boolean),
      TokenType::LPAREN => method(:parse_grouped_expression),
      TokenType::IF => method(:parse_if),
      TokenType::FUNCTION => method(:parse_function)
    }
  end

end
  

#   def parse_factor
#     if @current_token.token_type == TokenType::INT
#       value = @current_token.literal.to_i
#       consume(TokenType::INT)
#     elsif @current_token.token_type == TokenType::LPAREN
#       consume(TokenType::LPAREN)
#       value = parse_expression
#       consume(TokenType::RPAREN)
#     else
#       raise "Error de sintaxis: Se esperaba un número entero o paréntesis."
#     end
  
#     value
#   end
  

#   def consume(expected_token_type)
#     if @current_token.token_type == expected_token_type
#       @current_token = @lexer.next_token
#     else
#       raise "Error de sintaxis: Se esperaba #{expected_token_type}, pero se encontró #{@current_token.token_type}."
#     end
#   end

#   nuevas funciones, en desarrollo

#   def current_precedence
#     raise 'Assertion error' if @current_token.nil?
  
#     token_type = @current_token.token_type
#     return PRECEDENCES[token_type] if PRECEDENCES.key?(token_type)
  
#     Precedence::LOWEST
#   end
  


#   def advance_tokens
#     @current_token = @peek_token
#     @peek_token = @lexer.next_token
#   end




#   def parse_infix_expression(left)
#     raise 'Assertion error' if !@current_token.nil?
    
#     infix = Infix.new(@current_token, left, @current_token.operator)

#     precedence = current_precedence

#     advance_tokens

#     infix.right = parse_expression(precedence)
    
#     infix

#   end

#   def register_infix_fns
#     {
#       TokenType::PLUS => method(:parse_infix_expression),
#       TokenType::MINUS => method(:parse_infix_expression),
#       TokenType::DIVISION => method(:parse_infix_expression),
#       TokenType::MULTIPLICATION => method(:parse_infix_expression),
#       TokenType::EQ => method(:parse_infix_expression),
#       TokenType::NOT_EQ => method(:parse_infix_expression),
#       TokenType::LT => method(:parse_infix_expression),
#       TokenType::GT => method(:parse_infix_expression),
#       TokenType::LPAREN => method(:parse_call)
#     }
#   end
  
  
# end