require_relative 'token'
require_relative 'node'

class Parser
  class Error < StandardError; end

  def initialize(tokens)
    @tokens = tokens
    @current_token_index = 0
  end

  def parse
    primary
  end

  private

  def primary
    token = advance

    case token.token_type
    when TokenType::NUMBER then AST::Literal.new(token.literal)
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
end