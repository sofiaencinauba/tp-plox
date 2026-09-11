require_relative 'token'

class Scanner
  class Error < StandardError; end

  WHITESPACE = [' ', "\r", "\t", "\n"].freeze

  def initialize(source)
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

    if c == '/'
      if peek == '/'
        advance while peek != "\n" && !at_end?
      else
        add_token(TokenType::SLASH)
      end

    elsif (type = TokenType::DOUBLE_CHAR_TOKENS[c + peek])
      advance
      add_token(type)

    elsif (type = TokenType::SINGLE_CHAR_TOKENS[c])
      add_token(type)

    elsif c == '"'
      advance while peek != '"' && !at_end?
      raise Error, 'Unterminated string.' if at_end?

      advance

      literal = @source[(@start + 1)...(@current - 1)]
      add_token(TokenType::STRING, literal)

    elsif digit?(c)
      advance while digit?(peek) && !at_end?

      if peek == '.' && digit?(peek_next)
        advance
        advance while digit?(peek) && !at_end?

        raise Error, "Invalid number: #{lexeme}." if peek == '.'
      end

      add_token(TokenType::NUMBER, lexeme.to_f)

    elsif alpha?(c)
      advance while alpha_numeric?(peek) && !at_end?

      type = TokenType::TOKEN_KEYWORDS.fetch(
        lexeme.to_sym,
        TokenType::IDENTIFIER
      )

      add_token(type)

    else
      raise Error, "Unexpected character: #{c}"
    end
  end

  def add_token(type, literal = nil)
    @tokens << Token.new(type, lexeme, literal)
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

  def peek_next
    return "\0" if @current + 1 >= @source.length

    @source[@current + 1]
  end

  def alpha?(c)
    c.match?(/[a-zA-Z_]/)
  end

  def alpha_numeric?(c)
    alpha?(c) || digit?(c)
  end

  def at_end?
    @current >= @source.length
  end
end