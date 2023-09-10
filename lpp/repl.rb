require_relative 'lexer'
require_relative 'parser'
require_relative 'evaluator'
require_relative 'ast'

$EOF_TOKEN=Token.new(TokenType::EOF,'')
def star_repel()
    while (source=gets.chomp)!='salir()'
        lexer=Lexer.new(source)
        parser=Parser.new(lexer)
        program=parser.parse_program()
        evaluated=evaluate(program)

        if evaluated!=nil
            puts evaluated.inspect()
        end
    end
end

