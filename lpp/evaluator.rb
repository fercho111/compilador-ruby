require_relative 'ast'
require_relative 'objects'

TRUE = OBJECTS::Boolean.new(true)
FALSE = OBJECTS::Boolean.new(false)
NULL = OBJECTS::Null.new()

TYPE_MISMATCH = 'Discrepancia de tipos: {} {} {}'
UNKNOWN_PREFIX_OPERATOR = 'Operador desconocido: {}{}'
UNKNOWN_INFIX_OPERATOR = 'Operador desconocido: {} {} {}'
UNKNOWN_IDENTIFIER = 'Identificador no encontrado: {}'

def evaluate(node, env)
    node_type = node.class
  
    if node_type == AST::Program
      return evaluate_program(node, env)

    elsif node_type == AST::ExpressionStatement
      return evaluate(node.expression, env)

    elsif node_type == AST::Integer
      return Integer.new(node.value)

    elsif node_type == AST::Boolean
      return _to_boolean_object(node.value)

    elsif node_type == AST::Prefix
      right = evaluate(node.right, env)
      return _evaluate_prefix_expression(node.operator, right)

    elsif node_type == AST::Infix
      left = evaluate(node.left, env)
      right = evaluate(node.right, env)
      return _evaluate_infix_expression(node.operator, left, right)

    elsif node_type == AST::Block
      return _evaluate_block_statement(node, env)

    elsif node_type == AST::If
      return _evaluate_if_expression(node, env)

    elsif node_type == AST::ReturnStatement
      value = evaluate(node.return_value, env)
      return Return.new(value)

    elsif node_type == AST::LetStatement
      value = evaluate(node.value, env)
      env[node.name.value] = value
      
    elsif node_type == AST::Identifier
      return _evaluate_identifier(node, env)
    end
    return nil
  end
  
def evaluate_program(program, env)
    result = nil

    program.statements.each do |statement|
      result = evaluate(statement, env)

      if result.is_a?(OBJECTS::Return)
        result = result.value
        return result
      elsif result.is_a?(OBJECTS::Error)
        return result
      end
    end

    return result
end

def evaluate_bang_operator_expression(right)
    if right == TRUE
        return FALSE
    elsif right == FALSE
        return TRUE
    elsif right == NULL
        return TRUE
    else
        return FALSE
    end
end


def evaluate_minus_operator_expression(right)
    if right.instance_of?(Integer)
        return Integer.new(-right.value)
    end
    return NULL
end

def evaluate_prefix_expression(operator, right)
    if operator=='!'
        return _evaluate_bang_operator_expression(right)
    elsif operator=='-'
        return _evaluate_minus_operator_expression(right)
    else
        return NULL
    end
end

def evaluate_integer_infix_expression(operator, left, right)
    left_value =left.value
    right_value =right.value
    if operator == '+'
        return Integer.new(left_value+right_value)
    elsif operator == '-'
        return Integer.new(left_value-right_value)
    elsif operator == '*'
        return Integer.new(left_value*right_value)
    elsif operator == '/'
        return Integer.new(left_value / right_value)
    elsif operator == '<'
        return _to_boolean_object(left_value<right_value)
    elsif operator == '<='
        return _to_boolean_object(left_value<=right_value)
    elsif operator == '>'
        return _to_boolean_object(left_value>right_value)
    elsif operator == '>='
        return _to_boolean_object(left_value>=right_value)
    elsif operator == '=='
        return _to_boolean_object(left_value==right_value)
    elsif operator == '!='
        return _to_boolean_object(left_value!=right_value)
    end
    return NULL
end

def evaluate_infix_expression(operator, left, right)
    if left.instance_of?(Integer) && right.instance_of?(Integer)
        return __evaluate_integer_infix_expression(operator,left,right)
    elsif operator=='=='
        return to_boolean_object(left == right)
    elsif operator =='!='
        return to_boolean_object(left != right)
    end
    return NULL
end

def new_error(message, args)
    return Error.new("#{message} #{args.join(' ')}")
end
  

def to_boolean_object(value)
    return value ? TRUE : FALSE
end