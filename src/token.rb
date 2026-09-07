module TokenType
  # Token de un solo caracter
  LEFT_PAREN = :left_paren
  RIGHT_PAREN = :right_paren
  LEFT_BRACE = :left_brace
  RIGHT_BRACE = :right_brace
  COMMA = :comma
  DOT = :dot
  SEMICOLON = :semicolon
  STAR = :star
  PLUS = :plus
  MINUS = :minus
  BANG = :bang

  # Puede ser un slash, o dos slashes un comentario
  SLASH = :slash

  # Token de dos caracteres
  BANG_EQUAL = :bang_equal
  EQUAL_EQUAL = :equal_equal
  LESS_EQUAL = :less_equal
  GREATER_EQUAL = :greater_equal

  # Literales
  IDENTIFIER = :identifier
  STRING = :string
  NUMBER = :number

  # Palabras reservadas
  AND = :and
  ELSE = :else
  FALSE = false
  FUN = :fun
  FOR = :for
  IF = :if
  NIL = :nil
  OR = :or
  PRINT = :print
  RETURN = :return
  SUPER = :super
  THIS = :this
  TRUE = true
  VAR = :var
  WHILE = :while

  # End of file
  EOF = :eof

  SINGLE_CHAR_TOKENS = {
    '(' => TokenType::LEFT_PAREN,
    ')' => TokenType::RIGHT_PAREN,
    '{' => TokenType::LEFT_BRACE,
    '}' => TokenType::RIGHT_BRACE,
    ',' => TokenType::COMMA,
    '.' => TokenType::DOT,
    '-' => TokenType::MINUS,
    '+' => TokenType::PLUS,
    ';' => TokenType::SEMICOLON,
    '*' => TokenType::STAR,
    '!' => TokenType::BANG,
    '/' => TokenType::SLASH,
  }.freeze

  DOUBLE_CHAR_TOKENS = {
    '!=' => TokenType::BANG_EQUAL,
    '==' => TokenType::EQUAL_EQUAL,
    '<=' => TokenType::LESS_EQUAL,
    '>=' => TokenType::GREATER_EQUAL
  }.freeze

  TOKEN_KEYWORDS = {
    and: TokenType::AND,
    else: TokenType::ELSE,
    false => TokenType::FALSE,
    fun: TokenType::FUN,
    for: TokenType::FOR,
    if: TokenType::IF,
    nil: TokenType::NIL,
    or: TokenType::OR,
    print: TokenType::PRINT,
    return: TokenType::RETURN,
    super: TokenType::SUPER,
    this: TokenType::THIS,
    true => TokenType::TRUE,
    var: TokenType::VAR,
    while: TokenType::WHILE
  }.freeze
end

class Token
  attr_reader :token_type, :lexeme, :literal

  def initialize(token_type, lexeme = nil, literal = nil)
    @token_type = token_type
    @lexeme = lexeme
    @literal = literal
  end

  def inspect
    return "#{@token_type}<#{@lexeme}>" if @token_type == TokenType::IDENTIFIER

    @literal.nil? ? @token_type.to_s : "#{@token_type}<#{@literal}>"
  end
end
