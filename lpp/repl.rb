require_relative 'lexers'
require_relative 'tokens'
require_relative 'parser'

def start_repl
  loop do
      print '>> '
      source = gets.chomp
      break if source == "salir()"
      lexer = Lexers::Lexer.new(source)
      loop do
          token = lexer.next_token
          break if token.token_type == Tokens::EOF
          puts token
      end
  end
end

# def start_repl
#   loop do
#     print '>> '
#     source = gets.chomp
#     break if source == "salir()"

#     lexer = Lexers::Lexer.new(source)
#     parser = Parser.new(lexer)

#     begin
#       result = parser.parse
#       puts "Resultado: #{result}"
#     rescue StandardError => e
#       puts "#{e.message}"
#     end
#   end
# end