require_relative "lpp/evaluator"
require_relative "lpp/lexers"
require_relative "lpp/parsers"


environment = Evaluator::Environment.new
print '>> '
loop do
  code = gets.chomp
  lexer = Lexers::Lexer.new(code)
  parser = Parsers::Parser.new(lexer)
  program = parser.parse_program

  unless parser.errors.empty?
    puts "Whoops! we ran into some monkey business here!"
    puts " parser errors:"
    parser.errors.each { |error| puts "\t#{error}" }
    next
  end

  evaluated = Evaluator.evaluate(program, environment)
  puts evaluated.inspect unless evaluated.nil?

  print '>> '
end
