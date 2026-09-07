require_relative 'token.rb'

class Scanner
  class Error < StandardError; end
  WHITESPACE = [' ', "\r", "\t", "\n"].freeze

  def initialize(source)
    # Lista de tokens que se van a ir leyendo
    @tokens = []

    @source = source
    @start = 0
    @current = 0
  end

  def scan
    until at_end?
      @start = @current
      scan_token
    end

    @tokens
  end

  private

  def lexeme
    @source[@start...@current]
  end

  def scan_token
    c = advance

    return if WHITESPACE.include?(c)

    if (type = TokenType::DOUBLE_CHAR_TOKENS[c + peek])
      advance
      add_token(type)
    elsif (type = TokenType::SINGLE_CHAR_TOKENS[c])
      add_token(type)
    elsif c == '"'
      @start = @current
      advance while peek != '"' && !at_end?
      raise Error, 'Unterminated string.' if at_end?

      advance
      lexeme = @source[@start...@current - 1]
      add_token(TokenType::STRING, lexeme)

    elsif digit?(c)
	  @start = @current - 1
	  advance while digit?(peek) && !at_end?
	  
	  lexeme = @source[@start...@current]
      add_token(TokenType::NUMBER, lexeme)

	elsif is_alpha?(c)
	  @start = @current - 1
	  advance while is_alpha?(peek) && !at_end?

	  lexeme = @source[@start..@current]
	  add_token(TokenType::IDENTIFIER, lexeme)
    else
      raise Error, "Unexpected character: #{c}"
    end
  end

  def add_token(type, lexeme = nil, literal=nil)
    token = Token.new(type, lexeme, literal)
    @tokens << token
  end

  def peek
    return "\0" if at_end?

    @source[@current]
  end

  def advance
    previous = peek
    @current += 1
    previous
  end

  def digit?(c)
    c.match?(/\d/)
  end

  def is_alpha?(c)
    c.match(/[a-zA-Z_]/)
  end

  def at_end?
    @current >= @source.length
  end
end
