module Tokens
    class TokenType

        attr_reader :value

        def initialize(value)
          @value = value
        end
    
        def eql?(other)
          @value == other.value
        end
    
        def to_s
          @value
        end

    end

    ASSIGN = TokenType.new("ASSIGN")
    COMMA = TokenType.new("COMMA")
    DIVISION = TokenType.new("DIVISION")
    ELSE = TokenType.new("ELSE")
    EOF = TokenType.new("EOF")
    EQ = TokenType.new("EQ")
    FALSE = TokenType.new("FALSE")
    FOR = TokenType.new("FOR")
    FUNCTION = TokenType.new("FUNCTION")
    GT = TokenType.new("GT")
    IDENT = TokenType.new("IDENT")
    IF = TokenType.new("IF")
    ILLEGAL = TokenType.new("ILLEGAL")
    INT = TokenType.new("INT")
    LBRACE = TokenType.new("LBRACE")
    LET = TokenType.new("LET")
    LPAREN = TokenType.new("LPAREN")
    LT = TokenType.new("LT")
    MINUS = TokenType.new("MINUS")
    MULTIPLICATION = TokenType.new("MULTIPLICATION")
    NEGATION = TokenType.new("NEGATION")
    NOT_EQ = TokenType.new("NOT_EQ")
    PLUS = TokenType.new("PLUS")
    RBRACE = TokenType.new("RBRACE")
    RETURN = TokenType.new("RETURN")
    RPAREN = TokenType.new("RPAREN")
    SEMICOLON = TokenType.new("SEMICOLON")
    TRUE = TokenType.new("TRUE")

    class Token
        attr_reader :token_type, :literal

        def initialize(token_type, literal)
            @token_type = token_type
            @literal = literal
        end

        def to_s
            "Type: #{@token_type}, Literal: #{@literal}"
        end
    end

    def lookup_token_type(literal)
        keywords = {
            'variable' => LET,
            'funcion' => FUNCTION,
            'para' => FOR,
            'falso' => FALSE,
            'procedimiento' => FUNCTION,
            'regresa' => RETURN,
            'si' => IF,
            'si_no' => ELSE,
            'verdadero' => TRUE
        }

        keywords[literal] || IDENT
        
    end
end