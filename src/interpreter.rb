require_relative 'token'
require_relative 'node'

class Interpreter
  class Error < StandardError; end

  # def initialize(statements)
  #     @statements = statements
  # end

  def interpret(expression)
    value = evaluate(expression)
    puts value
  end

  private

  def evaluate(expr)
    case expr
    when AST::Literal
      expr.value
    when AST::Grouping
      evaluate(expr.expression)
    when AST::Unary
      evaluate_unary(expr)
    when AST::Binary
      evaluate_binary(expr)
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
