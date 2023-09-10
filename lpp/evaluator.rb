
require_relative '../../lib/elcompifiles/ast'
require_relative '../../lib/elcompifiles/objects'


TRUE=Boolean.new(true)
FALSE=Boolean.new(false)
NULL=Null.new()
def _evaluate_bang_operator_expression(right:Object)
    if right==TRUE
        return FALSE
    elsif right==FALSE
        return TRUE
    elsif right==NULL
        return TRUE
    else
        return FALSE
    end
    
end
def _to_boolean_object(value:bool)
    return TRUE if value else FALSE
end

def _evaluate_minus_operator_expression(right:Object)
    if right.class!=Integer
        return NULL
    end
    return Integer.new(-right.value)
end

def _evaluate_prefix_expression(operator:str,right:Object)
    if operator=='!'
        return _evaluate_bang_operator_expression(right)
    elsif operator=='-'
        return _evaluate_minus_operator_expression(right)
    else
        return NULL
    end
    
end
    
def __evaluate_integer_infix_expression(operator:str,
                                        left:Object,
                                        right:Object)
    left_value:int=left.value
    right_value:int=right.value
    if operator=='+'
        return Integer.new(left_value+right_value)
    elsif operator=='-'
        return Integer.new(left_value-right_value)
    elsif operator=='*'
        return Integer.new(left_value*right_value)
    elsif operator=='/'
        return Integer.new(left_value//right_value)
    elsif operator=='<'
        return _to_boolean_object(left_value<right_value)
    elsif operator=='<='
        return _to_boolean_object(left_value<=right_value)
    elsif operator=='>'
        return _to_boolean_object(left_value>right_value)
    elsif operator=='>='
        return _to_boolean_object(left_value>=right_value)
    elsif operator=='=='
        return _to_boolean_object(left_value==right_value)
    elsif operator=='!='
        return _to_boolean_object(left_value!=right_value)
    end
    return NULL
end
def _evaluate_infix_expression(operator:str,
                               left:Object,
                               right:Object)
    if left.class==Integer and right.class==Integer
        return __evaluate_integer_infix_expression(operator,left,right)
    elsif operator=='=='
        return _to_boolean_object(left is right)
    elsif operator =='!='
        return _to_boolean_object(left is not right)
    end
    return NULL
end

def evaluate(node: ast.ASTNode)
    node_type=node.class
    if node_type==ast.Program
        return _evaluate_statements(node.statements)
    elsif node_type==ast.ExpressionStatement
        return evaluate(node.expression)
    elsif node_type==ast.Integer
        return Integer
