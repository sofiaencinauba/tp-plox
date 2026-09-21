require_relative 'token'
require_relative 'ast_node'
require_relative 'expression'
require_relative 'statement'
require_relative 'env'

class Interpreter
  class Error < StandardError; end

  def initialize(environment = Env.new)
    @environment = environment
  end

  def interpret(node)
    if node.is_a?(AST::Program)
      node.statements.each { |statement| interpret(statement) }
    elsif node.is_a?(AST::Statement)
      execute(node)
    else
      puts evaluate(node)
    end
  end

  private

  def execute(statement)
    case statement
    when AST::VarDeclaration
      value = statement.initializer.nil? ? nil : evaluate(statement.initializer)
      @environment.define(statement.name.lexeme, value)
    when AST::PrintStatement
      puts evaluate(statement.expression)
    when AST::BlockStatement
      execute_block(statement.statements)
    when AST::IfStatement
      condition = evaluate(statement.condition)
      if truthy?(condition)
        interpret(statement.then_branch)
      elsif statement.else_branch
        interpret(statement.else_branch)
      end
    when AST::WhileStatement
      interpret(statement.body) while truthy?(evaluate(statement.condition))
    when AST::ForStatement
      execute(statement.initializer) if statement.initializer
      while statement.condition.nil? || truthy?(evaluate(statement.condition))
        interpret(statement.body)
        evaluate(statement.increment) if statement.increment
      end
    else
      raise Error, "Se encontró un tipo de statement desconocido: #{statement.class}"
    end
  end

  def execute_block(statements)
    previous_environment = @environment
    @environment = Env.new(previous_environment)
    statements.each { |statement| interpret(statement) }
  ensure
    @environment = previous_environment
  end

  def evaluate(expr)
    case expr
    when AST::Literal
      expr.value
    when AST::Variable
      @environment.get(expr.name.lexeme)
    when AST::Grouping
      evaluate(expr.expression)
    when AST::Unary
      evaluate_unary(expr)
    when AST::Binary
      evaluate_binary(expr)
    when AST::Logical
      left = evaluate(expr.left)
      if expr.operator.token_type == TokenType::AND
        return left unless truthy?(left)
        return evaluate(expr.right)
      elsif expr.operator.token_type == TokenType::OR
        return left if truthy?(left)
        return evaluate(expr.right)
      else
        raise Error, "Se encontró un operador lógico desconocido: #{expr.operator.token_type}"
      end
    else
      raise Error, "Se encontró un tipo de expresión desconocido: #{expr.class}"
    end
  end

  def evaluate_unary(expr)
    right = evaluate(expr.right)

    case expr.operator.token_type
    when TokenType::MINUS
      raise Error, "Se esperaba un número, se encontró #{right.class}." unless number?(right)

      -right
    when TokenType::BANG
      !truthy?(right)
    else
      raise Error, "Se encontró un operador desconocido: #{expr.operator.token_type}"
    end
  end

  def evaluate_binary(expr)
    left = evaluate(expr.left)
    right = evaluate(expr.right)

    case expr.operator.token_type
    when TokenType::PLUS
      unless number?(left, right) || string?(left, right)
        raise Error,
              "Se esperaba que ambos operandos fueran números o strings, se encontró #{left.class} y #{right.class}."
      end

      left + right
    when TokenType::MINUS
      unless number?(left, right)
        raise Error, "Se esperaba que ambos operandos fueran números, se encontró #{left.class} y #{right.class}."
      end

      left - right
    when TokenType::STAR
      unless number?(left, right)
        raise Error, "Se esperaba que ambos operandos fueran números, se encontró #{left.class} y #{right.class}."
      end

      left * right
    when TokenType::SLASH
      unless number?(left, right)
        raise Error, "Se esperaba que ambos operandos fueran números, se encontró #{left.class} y #{right.class}."
      end

      left / right
    when TokenType::EQUAL_EQUAL
      left == right
    when TokenType::BANG_EQUAL
      left != right
    when TokenType::GREATER
      unless number?(left, right)
        raise Error, "Se esperaba que ambos operandos fueran números, se encontró #{left.class} y #{right.class}."
      end

      left > right
    when TokenType::GREATER_EQUAL
      unless number?(left, right)
        raise Error, "Se esperaba que ambos operandos fueran números, se encontró #{left.class} y #{right.class}."
      end

      left >= right
    when TokenType::LESS
      unless number?(left, right)
        raise Error, "Se esperaba que ambos operandos fueran números, se encontró #{left.class} y #{right.class}."
      end

      left < right
    when TokenType::LESS_EQUAL
      unless number?(left, right)
        raise Error, "Se esperaba que ambos operandos fueran números, se encontró #{left.class} y #{right.class}."
      end

      left <= right
    else
      raise Error, "Se encontró un operador desconocido: #{expr.operator.token_type}"
    end
  end

  # Se hace asi y no directamente !right para que nil sea considerado falso
  def truthy?(value)
    value != false && !value.nil?
  end

  def number?(*values)
    values.all? { |value| value.is_a?(Integer) || value.is_a?(Float) }
  end

  def string?(*values)
    values.all? { |value| value.is_a?(String) }
  end
end
