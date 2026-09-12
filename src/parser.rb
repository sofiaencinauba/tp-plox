require_relative 'token'
require_relative 'node'

class Parser
  class Error < StandardError; end

  def initialize(tokens)
    @tokens = tokens
    @current_token_index = 0
  end

  def parse
    expression
  end

  private

  def expression
    # Si no hay tokens, devolvemos un nodo literal con valor nil
    return AST::Literal.new(nil) if at_end?

    # Si hay tokens, empezamos a parsear
    equality
  end

  def equality
    expr = comparison

    # Mientras sigamos con operadores de igualdad, seguimos construyendo la expresion
    while check(TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL)
      operator = advance
      right = comparison
      expr = AST::Binary.new(expr, operator, right)
    end

    expr
  end

  def comparison
    expr = term

    # Mientras sigamos con operadores de comparación, seguimos construyendo la expresion
    while check(TokenType::GREATER, TokenType::GREATER_EQUAL, TokenType::LESS, TokenType::LESS_EQUAL)
      operator = advance
      right = term
      expr = AST::Binary.new(expr, operator, right)
    end

    expr
  end

  def term
    expr = factor

    # Mientras sigamos con suma o resta, seguimos construyendo la expresion
    while check(TokenType::MINUS, TokenType::PLUS)
      operator = advance
      right = factor
      expr = AST::Binary.new(expr, operator, right)
    end

    expr
  end

  def factor
    expr = unary

    # Mientras sigamos con multiplicación o division, seguimos construyendo la expresion
    while check(TokenType::SLASH, TokenType::STAR)
      operator = advance
      right = unary
      expr = AST::Binary.new(expr, operator, right)
    end

    expr
  end

  # unary → ( "!" | "-" ) unary | primary
  def unary
    if check(TokenType::BANG, TokenType::MINUS)
      operator = advance
      right = unary
      return AST::Unary.new(operator, right)
    end

    primary
  end

  def primary
    token = advance

    case token.token_type
    # Si el token es un literal, devolvemos un nodo literal con su valor
    when TokenType::TRUE then AST::Literal.new(true)
    when TokenType::FALSE then AST::Literal.new(false)
    when TokenType::NIL then AST::Literal.new(nil)
    
    # Si en cambio es un numero o string, devolvemos un nodo literal con su valor
    when TokenType::NUMBER, TokenType::STRING then AST::Literal.new(token.literal)
    
    when TokenType::LEFT_PAREN
      expr = expression

      unless check(TokenType::RIGHT_PAREN)
        raise Error, "Se esperaba un paréntesis de cierre, se encontró #{peek.inspect}."
      end

      advance
      AST::Grouping.new(expr)

    else raise Error, "Se esperaba una expresión, se encontró #{token.inspect}."
    end
  end

  def peek
    @tokens[@current_token_index]
  end

  def advance
    token = peek
    @current_token_index += 1 unless at_end?
    token
  end

  def at_end?
    peek.token_type == TokenType::EOF
  end

  def check(*types)
    !at_end? && types.include?(peek.token_type)
  end
end
