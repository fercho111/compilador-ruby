require_relative 'tokens'

class Lexer

    def initialize(source)
        @source = source
        @character = ''
        @read_position = 0
        @position = 0
    end

    def next_token
        skip_whitespace

        if @character =~ /^=$/
            if peek_character == '='
                token = make_two_character_token(TokenType::EQ)
            else
                token = Token.new(TokenType::ASSIGN, @character)
            end



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
            ''
        end

        @source[@read_position]
    end

    def skip_whitespace
        while @character =~ /^\s$/
            read_character
        end
    end

end