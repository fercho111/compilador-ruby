require_relative 'lexer'
require_relative 'tokens'
require_relative 'parser'

def start_repl
  loop do
    print '>> '
    source = gets.chomp
    break if source == "salir()"

    lexer = Lexer.new(source)
    parser = Parser.new(lexer)

    begin
      result = parser.parse
      puts "Resultado: #{result}"
    rescue StandardError => e
      puts "Error: #{e.message}"
    end
  end
end

start_repl