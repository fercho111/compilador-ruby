require_relative 'ast'
require_relative 'lexer'
require_relative 'tokens'
require_relative 'parser'
require_relative 'objects'
require_relative 'evaluator'

def print_parse_errors(errors)
  for error in errors do
    puts error
  end
end

def start_repl
  loop do
    print '>> '
    source = gets.chomp
    break if source == "salir()"

    lexer = Lexer.new(source)
    parser = Parser.new(lexer)

    program = parser.parse_program()
    env = OBJECTS::Environment.new()

    if parser.errors.length > 0 
      print_parse_errors(parser.errors)
      next
    end

    evaluated = evaluate(program, env)

    if evaluated
      puts evaluated.inspect()
    end
  end
end