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

  :attr_reader errors

  def initialize(lexer)
    @lexer = lexer
    @current_token = nil
    @peek_token = nil
    @errors = []

    @prefix_parse_fns = register_prefix_fns
    @infix_parse_fns = register_infix_fns
    

  end

  def parse_program
    program = Program.new([])
    # assert
    while @current_token.token_type != TokenType::EOF
      statement = parse_statement
      if statement is not nil
        program.statements.push(statement)
      end
      advance_tokens
    end
    program
  end


  private

  # Modificaciones en el Parser
  # Agrega reglas para expresiones con paréntesis

  def advance_tokens
    @current_token = @peek_token
    @peek_token = @lexer.next_token
  end

  def current_precedence
    # assert
    PRECEDENCES.fetch(@current_token.token_type, Precedence::LOWEST)
  end


  def parse_call_arguments
    arguments = []
    # assert

    if @peek_token.token_type == TokenType::RPAREN
      advance_tokens
      return arguments
    end
    advance_tokens
    if (expression = parse_expression(Precedence::LOWEST))
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

  
  def parse_term
    left = parse_factor
  
    while [TokenType::MULTIPLICATION, TokenType::DIVISION].include?(@current_token.token_type)
      operator = @current_token
      consume(operator.token_type)
      right = parse_factor
  
      if operator.token_type == TokenType::MULTIPLICATION
        left *= right
      else
        left /= right
      end
    end
  
    left
  end
  
  def parse_factor
    if @current_token.token_type == TokenType::INT
      value = @current_token.literal.to_i
      consume(TokenType::INT)
    elsif @current_token.token_type == TokenType::LPAREN
      consume(TokenType::LPAREN)
      value = parse_expression
      consume(TokenType::RPAREN)
    else
      raise "Error de sintaxis: Se esperaba un número entero o paréntesis."
    end
  
    value
  end
  

  def consume(expected_token_type)
    if @current_token.token_type == expected_token_type
      @current_token = @lexer.next_token
    else
      raise "Error de sintaxis: Se esperaba #{expected_token_type}, pero se encontró #{@current_token.token_type}."
    end
  end

  # nuevas funciones, en desarrollo

  def current_precedence
    # raise 'Assertion error' if @current_token.nil?
  
    token_type = @current_token.token_type
    return PRECEDENCES[token_type] if PRECEDENCES.key?(token_type)
  
    Precedence::LOWEST
  end
  


  def advance_tokens
    @current_token = @peek_token
    @peek_token = @lexer.next_token
  end

  def expected_token(token_type)
    #assert
    if peek_token.token_type == token_type
      advance_tokens
      true
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
    block_statement = Block.new(@current_token, [])
    advance_tokens
    while !(@current_token.token_type == TokenType::RBRACE) && !(@current_token.token_type == TokenType::EOF)
      statement = parse_statement
      if statement
        block_statement.statements.push(statement)
      end
      advance_tokens
    end
    block_statement
  end

  def parse_boolean
    # assert
    Boolean.new(@current_token, @current_token.token_type == TokenType::TRUE)
  end

  def parse_call(function)
    # assert
    call = Call.new(@current_token, function)
    call.arguments = parse_call_arguments()
    return call
  end

  def parse_call_arguments
    arguments = []
    # assert
    if @peek_token.token_type == TokenType::RPAREN
      advance_tokens()
      return arguments
    end

    advance_tokens()

    if (expression = parse_expression(Precedence::LOWEST)) != nil
      arguments.append(expression)
    end

    while @peek_token.token_type == TokenType::COMMA
      advance_tokens()
      advance_tokens()
      
      if (expression = parse_expression(Precedence::LOWEST)) != nil
        arguments.push(expression)
      end
    end
    if expected_token(TokenType::RPAREN) == nil
      return nil
    end
    return arguments
  end

  def parse_expression(precedence)
    # assert
    
    prefix_parse_fn = @prefix_parse_fns[@current_token.token_type]
    if prefix_parse_fn == nil
      message = 'No se encontro ninguna funcion para parsear #{@current_token.literal}'
      @errors.push(message)
      return
    end
    left_expression = prefix_parse_fn
    # assert
    while !(@peek_token.token_type == TokenType::SEMICOLON) && precedence < peek_precedence()
      
      infix_parse_fn = infix_parse_fns[@peek_token.token_type]
      if infix_parse_fn == nil
        return left_expression
      end
      advance_tokens()
      # assert
      left_expression = infix_parse_fn(left_expression)
      return left_expression
  end
  
  def parse_expression_statement
    #assert
    expression_statement = ExpressionStatement.new(@current_token)
    expression_statement.expression = parse_expression(Precedence::LOWEST)
    # assert
    if @peek_token.token_type == TokenType::SEMICOLON
      advance_tokens()
    end
    return expression_statement
  end

  def parse_grouped_expression
    advance_tokens()
    expression = parse_expression(Precedence::LOWEST)
    if expected_token(TokenType::RPAREN) == nil
      return nil
    end
    return expression
  end

  def parse_functions
    # assert
    function = Function.new(@current_token)
    
    if expected_token(TokenType::LPAREN) == nil
      return nil
    end

    function.parameters = parse_function_parameters()

    if expected_token(TokenType::LBRACE) == nil
      return None
    end
    
    function.body = parse_block()

    return function
  end

  def parse_function_parameters
    params = []
    #assert
    if @peek_token.token_type == TokenType::RPAREN
      advance_tokens()
      return params
    end

    advance_tokens()

    #assert

    identifier = Identifier.new(@current_token, @current_token.literal)

    params.push(identifier)
    
    while @peek_token.token_type == TokenType::COMMA
      advance_tokens()
      advance_tokens()
      identifier = Identifier.new(@current_token, @current_token.literal)
      params.push(identifier)
    end

    if expected_token(TokenType::RPAREN) == nil
      return []
    end
    return params
  end

  def parse_identifier
    #assert
    return Identifier.new(@current_token, @current_token.literal)
  end

  def parse_if
    # assert
    if_expression = If.new(@current_token)
    if expected_token(TokenType::LPAREN) == nil
      return nil
    end

    advance_tokens()

    if_expression.condition = parse_expression(Precedence::LOWEST)

    if expected_token(TokenType::RPAREN) == nil
      return nil
    end

    if expected_token(TokenType::LBRACE) == nil
      return nil
    end

    if_expression.consequence = parse_block()

    #assert 
    if @peek_token.token_type == TokenType::ELSE
      advance_tokens()

      if expected_token(TokenType::LBRACE) == nil
        return nil
      end

      if_expression.alternative = parse_block()
    end
    return if_expression
  end

  def parse_integer
    raise "Current token is nil" if @current_token.nil?
  
    integer = Integer.new(@current_token)
  
    begin
      integer.value = Integer(@current_token.literal)
    rescue ArgumentError
      message = "No se ha podido parsear #{@current_token.literal} como entero."
      @errors.push
      (message)
      return nil
    end
  
    return integer
  end
  
  def parse_let_statement
    # assert
    let_statement = LetStatement.new(@current_token)

    if expected_token(TokenType::IDENT) == nil
      return nil
    end

    let_statement.name = parse_identifier()

    if expected_token(TokenType::ASSIGN) == nil
      return nil
    end

    advance_tokens()

    let_statement.value = parse_expression(Precedence::LOWEST)

    # assert
    if @peek_token.token_type == TokenType::SEMICOLON
      advance_tokens()
    end

    return let_statement
  end

  def parse_prefix_expression
    #assert
    prefix_expression = Prefix.new(@current_token, @current_token.literal)
    advance_tokens
    prefix_expression.right = parse_expression(Precedence::PREFIX)
    return prefix_expression
  end

  def parse_infix_expression(left)
    # raise 'Assertion error' if !@current_token.nil?
    #
    infix = Infix(@current_token, left, @current_token.operator)

    precedence = current_precedence

    advance_tokens

    infix.right = @parse_expression(precedence)
    
    infix

  end

  def parse_return_statement
    #assert
    return_statement = ReturnStatement.new(@current_token)
    advance_tokens
    return_statement.return_value = parse_expression(Precedence::LOWEST)
    # assert
    if @peek_token.token_type == TokenType::SEMICOLON
      advance_tokens
    end
    return return_statement
  end

  def parse_statement
    #assert
    if @current_token.token_type == TokenType::LET
      return parse_let_statement
    elsif @current_token.token_type == TokenType::RETURN
      return parse_return_statement
    else
      return parse_expression_statement
    end
  end
  
  def peek_precedence
    # assert
    precedence = PRECEDENCES[@peek_token.token_type]
    if precedence == nil
      return Precedence::LOWEST
    end
    return precedence
  end

  def register_prefix_fns
    {
      TokenType::FALSE => method(:parse_boolean),
      TokenType::FUNCTION => method(:parse_function),
      TokenType::IDENT => method(:parse_identifier),
      TokenType::IF => method(:parse_if),
      TokenType::INT => method(:parse_integer),
      TokenType::LPAREN => method(:parse_grouped_expression),
      TokenType::MINUS => method(:parse_prefix_expression),
      TokenType::NEGATION => method(:parse_prefix_expression),
      TokenType::TRUE => method(:parse_boolean),
    }
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
  
end