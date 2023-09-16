require_relative 'tokens'

class Parser
  def initialize(lexer)
    @lexer = lexer
    @current_token = @lexer.next_token
  end

  def parse
    parse_expression
  end

  private

  # Modificaciones en el Parser
# Agrega reglas para expresiones con paréntesis

def parse_expression
    left = parse_comparison 
  
    while [TokenType::PLUS, TokenType::MINUS].include?(@current_token.token_type)
      operator = @current_token
      consume(operator.token_type)
      right = parse_comparison 
  
      if operator.token_type == TokenType::PLUS
        left += right
      else
        left -= right
      end
    end
  
    left
  end

  def parse_comparison
    left = parse_term
    
    while [TokenType::LT, TokenType::GT, TokenType::LTEQ, TokenType::GTEQ].include?(@current_token.token_type)
      operator = @current_token
      consume(operator.token_type)
      right = parse_term
      
      if operator.token_type == TokenType::LT
        left = left < right
      elsif operator.token_type == TokenType::GT
        left = left > right
      elsif operator.token_type == TokenType::LTEQ
        left = left <= right
      elsif operator.token_type == TokenType::GTEQ
        left = left >= right
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
end