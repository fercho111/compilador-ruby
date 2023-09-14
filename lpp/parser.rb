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

  def parse_expression
    left = parse_term
  
    while [TokenType::PLUS, TokenType::MINUS].include?(@current_token.token_type)
      operator = @current_token
      consume(operator.token_type)
      right = parse_term
  
      if operator.token_type == TokenType::PLUS
        left += right
      else
        left -= right
      end
    end
  
    left
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




  def parse_infix_expression(left)
    # raise 'Assertion error' if !@current_token.nil?
    #
    infix = Infix(@current_token, left, @current_token.operator)

    precedence = current_precedence

    advance_tokens

    infix.right = @parse_expression(precedence)
    
    infix

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