require_relative 'token'

class Scanner
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

    return if [' ', "\r", "\t", "\n"].include?(c)

    if (type = TokenType::DOUBLE_CHAR_TOKENS[c + peek])
      advance
      add_token(type)
    elsif (type = TokenType::SINGLE_CHAR_TOKENS[c])
      add_token(type)
    elsif digit?(c)
      add_token(TokenType::NUMBER)
    else
      raise "Unexpected character: #{c}"
    end
  end

  def add_token(type)
    @tokens << { type: type }
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
    return true if c =~ /[0-9]/

    false
  end

  def at_end?
    @current >= @source.length
  end
end
