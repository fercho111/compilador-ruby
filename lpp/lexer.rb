require_relative 'tokens'

class Lexer
  
    attr_accessor :source  # Esto crea un getter y un setter para el atributo source

    def initialize(source)
        @source = source
        @character = ''
        @read_position = 0
        @position = 0
        read_character
    end

    def next_token
        skip_whitespace
      
        if @character =~ /^=$/
          if peek_character == '='
            token = make_two_character_token(TokenType::EQ)
          else
            token = Token.new(TokenType::ASSIGN, @character)
          end
        elsif @character =~ /^\+$/
          token = Token.new(TokenType::PLUS, @character)
        elsif @character =~ /^$/
          token = Token.new(TokenType::EOF, @character)
        elsif @character =~ /^\($/
          token = Token.new(TokenType::LPAREN, @character)
        elsif @character =~ /^\)$/
          token = Token.new(TokenType::RPAREN, @character)
        elsif @character =~ /^\{$/
          token = Token.new(TokenType::LBRACE, @character)
        elsif @character =~ /^\}$/
          token = Token.new(TokenType::RBRACE, @character)
        elsif @character =~ /^,$/
          token = Token.new(TokenType::COMMA, @character)
        elsif @character =~ /^;$/
          token = Token.new(TokenType::SEMICOLON, @character)
        elsif @character =~ /^-$/
          token = Token.new(TokenType::MINUS, @character)
        elsif @character =~ /^\/$/
          token = Token.new(TokenType::DIVISION, @character)
        elsif @character =~ /^\*$/
          token = Token.new(TokenType::MULTIPLICATION, @character)
        elsif @character =~ /^<$/
          token = Token.new(TokenType::LT, @character)
        elsif @character =~ /^>$/
          token = Token.new(TokenType::GT, @character)
        elsif @character =~ /^!$/
          if peek_character == '='
            token = make_two_character_token(TokenType::NOT_EQ)
          else
            token = Token.new(TokenType::NEGATION, @character)
          end
        elsif is_letter(@character)
          literal = read_identifier
          token_type = lookup_token_type(literal)
          return Token.new(token_type, literal)
        elsif is_number(@character)
          literal = read_number
          return Token.new(TokenType::INT, literal)
        else
          token = Token.new(TokenType::ILLEGAL, @character)
        end
      
        read_character
        token
      end
      

    private

    def is_letter(character)
        character =~ /^[a-záéíóúA-ZÁÉÍÓÚñÑ_]$/
    end

    def is_number(character)
        character =~ /^\d$/
    end

    def make_two_character_token(token_type)
        prefix = @character
        read_character
        suffix = @character
        Token.new(token_type, "#{prefix}#{suffix}")
    end

    def read_character
        if @read_position >= @source.length
            @character = ''
        else
            @character = @source[@read_position]
        end
        @position = @read_position
        @read_position += 1

    end

    def read_identifier
        initial_position = @position
        is_first_letter = true
        while is_letter(@character) || (!is_first_letter && is_number(@character))
            read_character
            is_first_letter = false
        end
        @source[initial_position,@position]
    end

    def read_number
        initial_position = @position

        while is_number(@character)
            read_character
        end

        @source[initial_position,@position]
    end

    def peek_character
        if @read_position >= @source.length
            return ''
        end

        @source[@read_position]
    end

    def skip_whitespace
        while @character =~ /^\s$/
            read_character
        end
    end

end