require_relative 'lexer'
require_relative 'tokens'

# EOF_TOKEN = Token.new(TokenType::EOF, '')

def start_repl
    loop do
        print '>> '
        source = gets.chomp
        break if source == "salir()"
        lexer = Lexer.new(source)
        loop do
            token = lexer.next_token
            break if token.token_type == :EOF
            puts token
        end
    end
end