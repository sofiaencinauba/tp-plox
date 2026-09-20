require_relative 'token'
require_relative 'ast_node'
require_relative 'expression'
require_relative 'statement'

class Parser
  class Error < StandardError; end

  def initialize(tokens)
    @tokens = tokens
    @current_token_index = 0
  end

  def parse
    statements = []
    until at_end?
      statements << statement

      unless check(TokenType::SEMICOLON)
        raise Error, "Se esperaba ';' después de la instrucción, se encontró #{peek.inspect}."
      end

      advance
    end

    AST::Program.new(statements)
  end

  private

  def statement
    case peek.token_type
    when TokenType::VAR
      advance
      var_declaration
    when TokenType::PRINT
      advance
      print_statement
    when TokenType::LEFT_BRACE
      advance
      block_statement
    when TokenType::IF
      advance
      if_statement
    when TokenType::WHILE
      advance
      while_statement
    when TokenType::FOR
      advance
      for_statement
    else
      expression
    end
  end

  def var_declaration
    raise Error, "Se esperaba un nombre de variable, se encontró #{peek.inspect}." unless check(TokenType::IDENTIFIER)

    name = advance
    initializer = nil

    if check(TokenType::EQUAL)
      advance
      raise Error, 'Se esperaba una expresión después de =.' if at_end?

      initializer = expression
    end

    AST::VarDeclaration.new(name, initializer)
  end

  def print_statement
    raise Error, 'Se esperaba una expresión después de print.' if at_end?

    AST::PrintStatement.new(expression)
  end

  def block_statement
    statements = []

    until at_end? || check(TokenType::RIGHT_BRACE)
      statements << statement
      unless check(TokenType::SEMICOLON)
        raise Error, "Se esperaba ';' después de la instrucción, se encontró #{peek.inspect}."
      end

      advance
    end

    unless check(TokenType::RIGHT_BRACE)
      raise Error, "Se esperaba '}' al final del bloque, se encontró #{peek.inspect}."
    end

    advance
    AST::BlockStatement.new(statements)
  end

  def if_statement
    raise Error, "Se esperaba '(' después de if, se encontró #{peek.inspect}." unless check(TokenType::LEFT_PAREN)

    advance

    condition = expression

    unless check(TokenType::RIGHT_PAREN)
      raise Error, "Se esperaba ')' después de la condición, se encontró #{peek.inspect}."
    end

    advance

    then_branch = statement

    if check(TokenType::ELSE)
      advance
      else_branch = statement
    else
      else_branch = nil
    end

    AST::IfStatement.new(condition, then_branch, else_branch)
  end

  def while_statement
    raise Error, "Se esperaba '(' después de while, se encontró #{peek.inspect}." unless check(TokenType::LEFT_PAREN)

    advance

    condition = expression

    unless check(TokenType::RIGHT_PAREN)
      raise Error, "Se esperaba ')' después de la condición, se encontró #{peek.inspect}."
    end

    advance

    body = statement

    AST::WhileStatement.new(condition, body)
  end

  def expression
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

    when TokenType::IDENTIFIER then AST::Variable.new(token)

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
