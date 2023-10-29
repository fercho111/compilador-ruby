module TokenType
    ASSIGN = :ASSIGN
    COMMA = :COMMA
    DIVISION = :DIVISION
    ELSE = :ELSE
    EOF = :EOF
    EQ = :EQ
    FALSE = :FALSE
    FOR = :FOR
    FUNCTION = :FUNCTION
    GT = :GT
    IDENT = :IDENT
    IF = :IF
    ILLEGAL = :ILLEGAL
    INT = :INT
    LBRACE = :LBRACE
    LET = :LET
    LPAREN = :LPAREN
    LT = :LT
    MINUS = :MINUS
    MULTIPLICATION = :MULTIPLICATION
    NEGATION = :NEGATION
    NOT_EQ = :NOT_EQ
    PLUS = :PLUS
    RBRACE = :RBRACE
    RETURN = :RETURN
    RPAREN = :RPAREN
    SEMICOLON = :SEMICOLON
    TRUE = :TRUE
end

def lookup_token_type(literal)
    keywords = {
        'variable' => TokenType::LET,
        'funcion' => TokenType::FUNCTION,
        'para' => TokenType::FOR,
        'falso' => TokenType::FALSE,
        'procedimiento' => TokenType::FUNCTION,
        'regresa' => TokenType::RETURN,
        'si' => TokenType::IF,
        'si_no' => TokenType::ELSE,
        'verdadero' => TokenType::TRUE
    }

    keywords[literal] || TokenType::IDENT
end
    
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