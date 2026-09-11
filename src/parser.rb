require_relative 'token'
require_relative 'node'

class Parser
  class Error < StandardError; end

  def initialize(tokens)
    @tokens = tokens
    @current_token_index = 0
  end

  def parse
    unary
  end

  private

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
    when TokenType::NUMBER, TokenType::STRING then AST::Literal.new(token.literal)
    when TokenType::TRUE then AST::Literal.new(true)
    when TokenType::FALSE then AST::Literal.new(false)
    when TokenType::NIL then AST::Literal.new(nil)
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