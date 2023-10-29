require_relative 'tokens'
require_relative 'ast'
require_relative 'lexers'

module Parsers
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
    Tokens::EQ => Precedence::EQUALS,
    Tokens::NOT_EQ => Precedence::EQUALS,
    Tokens::LT => Precedence::LESSGREATER,
    Tokens::GT => Precedence::LESSGREATER,
    Tokens::PLUS => Precedence::SUM,
    Tokens::MINUS => Precedence::SUM,
    Tokens::DIVISION => Precedence::PRODUCT,
    Tokens::MULTIPLICATION => Precedence::PRODUCT,
    Tokens::LPAREN => Precedence::CALL
  }.freeze

  class Parser

    attr_reader :errors

    def initialize(lexer)
      @lexer = lexer
      @current_token = nil
      @peek_token = nil
      @errors = []

      @prefix_parsers = {
        Tokens::FALSE => method(:parse_boolean),
        Tokens::FUNCTION => method(:parse_function),
        Tokens::IDENT => method(:parse_identifier),
        Tokens::IF => method(:parse_if),
        Tokens::INT => method(:parse_integer),
        Tokens::LPAREN => method(:parse_grouped_expression),
        Tokens::MINUS => method(:parse_prefix_expression),
        Tokens::NEGATION => method(:parse_prefix_expression),
        Tokens::TRUE => method(:parse_boolean),
      }.freeze

      @infix_parsers = {
        Tokens::PLUS => method(:parse_infix_expression),
        Tokens::MINUS => method(:parse_infix_expression),
        Tokens::DIVISION => method(:parse_infix_expression),
        Tokens::MULTIPLICATION => method(:parse_infix_expression),
        Tokens::EQ => method(:parse_infix_expression),
        Tokens::NOT_EQ => method(:parse_infix_expression),
        Tokens::LT => method(:parse_infix_expression),
        Tokens::GT => method(:parse_infix_expression),
        Tokens::LPAREN => method(:parse_call)
      }.freeze
      advance_tokens
      advance_tokens
    end

    def parse_program
      program = AST::Program.new([])
      while @current_token.token_type != Tokens::EOF
        statement = parse_statement
        if statement != nil
          program.statements.push(statement)
        end
        advance_tokens
      end
      program
    end

    private

    def advance_tokens
      @current_token = @peek_token
      @peek_token = @lexer.next_token
    end

    def current_precedence
      # assert
      PRECEDENCES.fetch(@current_token.token_type, Precedence::LOWEST)
    end
    
    def current_precedence
      # raise 'Assertion error' if @current_token.nil?
    
      token_type = @current_token.token_type
      return PRECEDENCES[token_type] if PRECEDENCES.key?(token_type)
    
      Precedence::LOWEST
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
      block_statement = AST::Block.new(@current_token, [])
      advance_tokens
      while !(@current_token.token_type == Tokens::RBRACE) && !(@current_token.token_type == Tokens::EOF)
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
      AST::Boolean.new(@current_token, @current_token.token_type == Tokens::TRUE)
    end

    def parse_call(function)
      token = @current_token
      arguments = parse_call_arguments(Tokens::RPAREN)
      AST::CallExpression.new(token, function, arguments)
    end


    def peek_token_is?(token_type)
      @peek_token.type == token_type
    end

    # perhaps
    def parse_call_arguments
      arguments = []
      if @peek_token.token_type == Tokens::RPAREN
        advance_tokens()
        return arguments
      end

      advance_tokens()

      if (expression = parse_expression(Precedence::LOWEST)) != nil
        arguments.append(expression)
      end

      while @peek_token.token_type == Tokens::COMMA
        advance_tokens()
        advance_tokens()
        
        if (expression = parse_expression(Precedence::LOWEST)) != nil
          arguments.push(expression)
        end
      end
      if expected_token(Tokens::RPAREN) == nil
        return nil
      end
      return arguments
    end

    # no se si esto funcione
    def parse_expression(precedence)
      prefix = @prefix_parsers[@current_token.token_type]
      if prefix.nil?
        # no_prefix_parse_error(@curent_token.token_type)
        return nil
      end
      left = prefix.call
      while !peek_token_is?(Tokens::SEMICOLON) && precedence < peek_precedence
        infix = @infix_parsers[@peek_token.type]
        return left if infix.nil?

        advance_tokens
        left = infix.call(left)
      end
      left
    end
    
    def parse_expression_statement
      token = @current_token
      expression = parse_expression(Precedence::LOWEST)
      advance_tokens if peek_token_is?(Tokens::SEMICOLON)
      AST::ExpressionStatement.new(token, expression)
    end

    def parse_grouped_expression
      advance_tokens
      expression = parse_expression(Precedence::LOWEST)
      if expected_token(Tokens::RPAREN) == nil
        return nil
      end
      return expression
    end

    def parse_function

      function = Function.new(@current_token)
      
      if expected_token(Tokens::LPAREN) == nil
        return nil
      end

      function.parameters = parse_function_parameters()

      if expected_token(Tokens::LBRACE) == nil
        return None
      end
      
      function.body = parse_block()

      return function
    end

    def parse_function_parameters
      params = []
      if @peek_token.token_type == Tokens::RPAREN
        advance_tokens
        return params
      end

      advance_tokens

      identifier = Identifier.new(@current_token, @current_token.literal)

      params.push(identifier)
      
      while @peek_token.token_type == Tokens::COMMA
        advance_tokens
        advance_tokens
        identifier = Identifier.new(@current_token, @current_token.literal)
        params.push(identifier)
      end

      if expected_token(Tokens::RPAREN) == nil
        return []
      end
      return params
    end

    def parse_identifier
      return AST::Identifier.new(@current_token, @current_token.literal)
    end

    def parse_if
      token = @current_token

      return nil unless expect_peek?(Tokens::LPAREN)

      advance_tokens
      condition = parse_expression(Precedence::LOWEST)
      return nil unless expect_peek?(Tokens::RPAREN)

      return nil unless expect_peek?(Tokens::LBRACE)

      consequence = parse_block_statement

      alternative = if peek_token_is?(Tokens::ELSE)
                      advance_tokens
                      return nil unless expect_peek?(Tokens::LBRACE)

                      parse_block_statement
                    end

      AST::If.new(token, condition, consequence, alternative)
    end

    def parse_integer
      token = @current_token
      value = token.literal.to_i
      AST::Integer.new(token, value)   
    end
    
    def parse_let_statement
      token = @current_token
      return nil unless expect_peek?(Tokens::IDENT)

      name = AST::Identifier.new(@current_token, @current_token.literal)
      return nil unless expect_peek?(Tokens::ASSIGN)

      advance_tokens
      value = parse_expression(Precedence::LOWEST)
      advance_tokens if peek_token_is?(Tokens::SEMICOLON)
      Ast::LetStatement.new(token, name, value)
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
      infix = Infix.new(@current_token, left, @current_token.operator)

      precedence = current_precedence

      advance_tokens

      infix.right = parse_expression(precedence)
      
      infix

    end

    def parse_return_statement
      token = @current_token
      advance_tokens
      return_value = parse_expression(Precedence::LOWEST)
      advance_tokens while peek_token_is(Tokens::SEMICOLON)
      AST::ReturnStatement.new(token, return_value)
    end

    def parse_statement
      case @current_token.token_type
      when Tokens::LET
        parse_let_statement
      when Tokens::RETURN
        parse_return_statement
      else
        parse_expression_statement
      end
    end
    
    def peek_precedence
      precedence = PRECEDENCES[@peek_token.token_type]
      if precedence == nil
        return Precedence::LOWEST
      end
      return precedence
    end

    def peek_token_is(token_type)
      @peek_token.token_type == token_type
    end

    def expect_peek?(token_type)
      if peek_token_is(token_type)
        advance_tokens
        true
      else
        peek_error(token_type)
        false
      end
    end

    def peek_error(token_type)
      @errors << "Expected next token to be #{token_type}, got #{@peek_token.type} instead"
    end

    # def register_prefix_fns
    #   {
    #     Tokens::FALSE => method(:parse_boolean),
    #     Tokens::FUNCTION => method(:parse_function),
    #     Tokens::IDENT => method(:parse_identifier),
    #     Tokens::IF => method(:parse_if),
    #     Tokens::INT => method(:parse_integer),
    #     Tokens::LPAREN => method(:parse_grouped_expression),
    #     Tokens::MINUS => method(:parse_prefix_expression),
    #     Tokens::NEGATION => method(:parse_prefix_expression),
    #     Tokens::TRUE => method(:parse_boolean),
    #   }
    # end

    # def register_infix_fns
    #   {
    #     Tokens::PLUS => method(:parse_infix_expression),
    #     Tokens::MINUS => method(:parse_infix_expression),
    #     Tokens::DIVISION => method(:parse_infix_expression),
    #     Tokens::MULTIPLICATION => method(:parse_infix_expression),
    #     Tokens::EQ => method(:parse_infix_expression),
    #     Tokens::NOT_EQ => method(:parse_infix_expression),
    #     Tokens::LT => method(:parse_infix_expression),
    #     Tokens::GT => method(:parse_infix_expression),
    #     Tokens::LPAREN => method(:parse_call)
    #   }
    # end

  end
end