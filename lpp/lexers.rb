require_relative "tokens"
include Tokens

module Lexers
  class Lexer
    def initialize(source)
      @source = source
      @character = ''
      @read_position = 0
      @position = 0
      read_character
    end

    def next_token
      skip_whitespace
      r = nil
      if @character =~ /^=$/
        if peek_character == '='
          token = make_two_character_token(Tokens::EQ)
        else
          token = Tokens::Token.new(Tokens::ASSIGN, @character)
        end
      elsif @character =~ /^\+$/
        token = Tokens::Token.new(Tokens::PLUS, @character)
      elsif @character =~ /^$/
        token = Tokens::Token.new(Tokens::EOF, @character)
      elsif @character =~ /^\($/
        token = Tokens::Token.new(Tokens::LPAREN, @character)
      elsif @character =~ /^\)$/
        token = Tokens::Token.new(Tokens::RPAREN, @character)
      elsif @character =~ /^\{$/
        token = Tokens::Token.new(Tokens::LBRACE, @character)
      elsif @character =~ /^\}$/
        token = Tokens::Token.new(Tokens::RBRACE, @character)
      elsif @character =~ /^,$/
        token = Tokens::Token.new(Tokens::COMMA, @character)
      elsif @character =~ /^;$/
        token = Tokens::Token.new(Tokens::SEMICOLON, @character)
      elsif @character =~ /^-$/
        token = Tokens::Token.new(Tokens::MINUS, @character)
      elsif @character =~ /^\/$/
        token = Tokens::Token.new(Tokens::DIVISION, @character)
      elsif @character =~ /^\*$/
        token = Tokens::Token.new(Tokens::MULTIPLICATION, @character)
      elsif @character =~ /^<$/
        token = Tokens::Token.new(Tokens::LT, @character)
      elsif @character =~ /^>$/
        token = Tokens::Token.new(Tokens::GT, @character)
      elsif @character =~ /^!$/
        if peek_character == '='
          token = make_two_character_token(Tokens::NOT_EQ)
        else
          token = Tokens::Token.new(Tokens::NEGATION, @character)
        end
      elsif is_letter(@character)
        literal = read_identifier
        token_type = Tokens::lookup_token_type(literal)
        return Tokens::Token.new(token_type, literal)
      elsif is_number(@character)
        literal = read_number
        return Tokens::Token.new(Tokens::INT, literal)
      else
        token = Tokens::Token.new(Tokens::ILLEGAL, @character)
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
      Tokens::Token.new(token_type, "#{prefix}#{suffix}")
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

    def skip_whitespace
      while @character =~ /^\s$/
          read_character
      end
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

    def peek_character
      if @read_position >= @source.length
          return ''
      end

      @source[@read_position]
    end

  end

end