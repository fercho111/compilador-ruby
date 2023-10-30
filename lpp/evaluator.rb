# frozen_string_literal: true

require_relative "objects"
require_relative "tokens"
include Tokens

module Evaluator
  M_TRUE = Objects::MBoolean.new(true)
  M_FALSE = Objects::MBoolean.new(false)


  class Environment
    attr_reader :store, :outer

    def initialize(store = {}, outer = nil)
      @store = store
      @outer = outer
    end

    def []=(name, value)
      @store[name] = value
    end

    def [](name)
      obj = @store[name]
      if obj.nil? && !@outer.nil?
        @outer[name]
      else
        obj
      end
    end
  end

  def self.evaluate(program, environment)
    result = nil
    program.statements.each do |statement|
      result = inner_eval(statement, environment)
      case result
      when Objects::MReturnValue
        return result.value
      when Objects::MError
        return result
      end
    end
    result
  end

  def self.inner_eval(node, environment)
    case node
    when Ast::Identifier
      eval_identifier(node, environment)
    when Ast::IntegerLiteral
      Objects::MInteger.new(node.value)
    when Ast::InfixExpression
      inner_eval(node.left, environment).if_not_error do |left|
        inner_eval(node.right, environment).if_not_error do |right|
          eval_infix_expression(node.operator, left, right)
        end
      end
    when Ast::BlockStatement
      eval_block_statement(node, environment)
    when Ast::ExpressionStatement
      inner_eval(node.expression, environment)
    when Ast::IfExpression
      eval_if_expression(node, environment)
    when Ast::CallExpression
      inner_eval(node.function, environment).if_not_error do |function|
        args = eval_expressions(node.arguments, environment)
        if args.size == 1 && args[0].error?
          args[0]
        else
          apply_function(function, args)
        end
      end
    when Ast::ReturnStatement
      inner_eval(node.return_value, environment).if_not_error do |value|
        Objects::MReturnValue.new(value)
      end
    when Ast::PrefixExpression
      inner_eval(node.right, environment).if_not_error do |right|
        eval_prefix_expression(node.operator, right)
      end
    when Ast::BooleanLiteral
      node.value.to_m
    when Ast::LetStatement
      inner_eval(node.value, environment).if_not_error do |value|
        environment[node.name.value] = value
      end
    when Ast::FunctionLiteral
      Objects::MFunction.new(node.parameters, node.body, environment)
    else
      p node
      nil
    end
  end

  def self.eval_minus_prefix_operator_expression(right)
    if right.nil?
      nil
    else
      case right
      when Objects::MInteger
        -right
      else
        Objects::MError.new("unknown operator: -#{right.type_desc}")
      end
    end
  end


  def self.eval_bang_operator_expression(right)
    case right
    when M_TRUE
      M_FALSE
    when M_FALSE
      M_TRUE
    when Objects::M_NULL
      M_TRUE
    else
      M_FALSE
    end
  end

  def self.eval_expressions(arguments, environment)
    arguments.map do |argument|
      evaluated = inner_eval(argument, environment)
      return [evaluated] if evaluated.error?

      evaluated
    end
  end

  def self.apply_function(function, args)
    case function
    when Objects::MFunction
      extend_env = extend_function_env(function, args)
      evaluated = inner_eval(function.body, extend_env)
      unwrap_return_value(evaluated)
    else
      Objects::MError.new("not a function: #{function.type_desc}")
    end
  end

  def self.extend_function_env(function, args)
    env = Environment.new({}, function.environment)
    function.parameters&.each_with_index do |identifier, i|
      env[identifier.value] = args[i]
    end
    env
  end

  def self.unwrap_return_value(obj)
    case obj
    when Objects::MReturnValue
      obj.value
    else
      obj
    end
  end

  def self.eval_identifier(identifier, environment)
    value = environment[identifier.value]
    if value.nil?
        Objects::MError.new("identifier not found: #{identifier.value}")
    else
      value
    end
  end

  def self.eval_prefix_expression(operator, right)
    case operator
    when "!"
      eval_bang_operator_expression(right)
    when "-"
      eval_minus_prefix_operator_expression(right)
    else
      Objects::MError.new("Unknown operator : #{operator}#{right.type_desc}")
    end
  end

  def self.eval_integer_infix_expression(operator, left, right)
    case operator
    when "+"
      left + right
    when "-"
      left - right
    when "*"
      left * right
    when "/"
      left / right
    when "<"
      (left < right).to_m
    when ">"
      (left > right).to_m
    when "=="
      (left == right).to_m
    when "!="
      (left != right).to_m
    else
      Objects::MError.new("unknown operator: #{left.type_desc} #{operator} #{right.type_desc}")
    end
  end

  def self.eval_infix_expression(operator, left, right)
    if left.is_a?(Objects::MInteger) && right.is_a?(Objects::MInteger)
      eval_integer_infix_expression(operator, left, right)
    elsif operator == "=="
      (left == right).to_m
    elsif operator == "!="
      (left != right).to_m
    elsif left.type_desc != right.type_desc
      Objects::MError.new("type mismatch: #{left.type_desc} #{operator} #{right.type_desc}")
    else
      Objects::MError.new("unknown operator: #{left.class} #{operator} #{right.class}")
    end
  end

  def self.eval_if_expression(if_expression, environment)
    inner_eval(if_expression.condition, environment).if_not_error do |condition|
      if condition.truthy?
        inner_eval(if_expression.consequence, environment)
      elsif !if_expression.alternative.nil?
        inner_eval(if_expression.alternative, environment)
      else
        Objects::M_NULL
      end
    end
  end

  def self.eval_block_statement(block_statement, environment)
    result = nil
    block_statement.statements.each do |statement|
      result = inner_eval(statement, environment)
      return result if result.is_a?(Objects::MReturnValue) || result.is_a?(Objects::MError)
    end
    result
  end
end

class TrueClass
  def to_m
    Objects::MBoolean.new(true)
  end
end

class FalseClass
  def to_m
    Objects::MBoolean.new(false)
  end
end

class NilClass
  def if_not_error(&)
    self
  end

  def error?
    false
  end

  def type_desc
    "nil"
  end
end
