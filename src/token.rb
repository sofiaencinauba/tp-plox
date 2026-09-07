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
  EOF = :eof
  BANG = :bang

  # Token de dos caracteres
  BANG_EQUAL = :bang_equal
  EQUAL_EQUAL = :equal_equal
  LESS_EQUAL = :less_equal
  GREATER_EQUAL = :greater_equal

  # Literales
  IDENTIFIER = :identifier
  STRING = :string
  NUMBER = :number

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
    '!' => TokenType::BANG
  }.freeze

  DOUBLE_CHAR_TOKENS = {
    '!=' => TokenType::BANG_EQUAL,
    '==' => TokenType::EQUAL_EQUAL,
    '<=' => TokenType::LESS_EQUAL,
    '>=' => TokenType::GREATER_EQUAL
  }.freeze
end
