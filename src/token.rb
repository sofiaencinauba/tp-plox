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
    '*' => TokenType::STAR
  }.freeze

    DOUBLE_CHAR_TOKENS = {
    '!=' => :bang_equal,
    '==' => :equal_equal,
    '<=' => :less_equal,
    '>=' => :greater_equal
    }.freeze
end