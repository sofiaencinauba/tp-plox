Feature: Scanner

    Rule: The scanner should correctly tokenize a simple literal
    Scenario: Tokenizing a simple literal
    Given the source code is:
    """
    1;
    """
    When the scanner is run
    Then the following tokens should be produced:
      | Token Type | Lexeme |
      | NUMBER     | 1      |
      | SEMICOLON  | ;      |

    Rule: The scanner should correctly tokenize a binary operation
    Scenario: Tokenizing a binary operation
    Given the source code is:
    """
    1 + 2;
    """
    When the scanner is run
    Then the following tokens should be produced:
      | Token Type | Lexeme |
      | NUMBER     | 1      |
      | PLUS     | +      |
      | NUMBER     | 2      |
      | SEMICOLON  | ;      |
    


    Rule: The scanner should correctly tokenize a unary operation
    Scenario: Tokenizing a unary operation
    Given the source code is:
    """
    -1;
    """
    When the scanner is run
    Then the following tokens should be produced:
      | Token Type | Lexeme |
      | MINUS     | -      |
      | NUMBER     | 1      |
      | SEMICOLON  | ;      |   
    
    Rule: The scanner should correctly tokenize a variable declaration
    Scenario: Tokenizing a variable declaration
    Given the source code is:
    """
    var x = 42;
    """
    When the scanner is run
    Then the following tokens should be produced:
      | Token Type | Lexeme |
      | VAR    | var    |
      | IDENTIFIER | x      |
      | EQUAL     | =      |
      | NUMBER     | 42     |
      | SEMICOLON  | ;      |
    
    Rule: The scanner should correctly tokenize a function declaration
    Scenario: Tokenizing a function declaration
    Given the source code is:
    """
    fun add(a, b) {
        return a + b;
    }
    """
    When the scanner is run
    Then the following tokens should be produced:
      | Token Type | Lexeme |
      | FUN    | fun    |
      | IDENTIFIER | add    |
      | LEFT_PAREN     | (      |
      | IDENTIFIER | a      |
      | COMMA     | ,      |   
      | IDENTIFIER | b      |
      | RIGHT_PAREN     | )      |
      | LEFT_BRACE     | {      |
      | RETURN    | return |
      | IDENTIFIER | a      |
      | PLUS     | +      | 
      | IDENTIFIER | b      |
      | SEMICOLON  | ;      |
      | RIGHT_BRACE     | }      |
    
    Rule: The scanner should correctly tokenize a string literal
    Scenario: Tokenizing a string literal
    Given the source code is:
    """
    "Hello, World!";
    """
    When the scanner is run
    Then the following tokens should be produced:
      | Token Type | Lexeme          |
      | STRING     | "Hello, World!" |
      | SEMICOLON  | ;               |
    
    Rule: The scanner should fail gracefully on invalid input
    Scenario: Tokenizing invalid input
    Given the source code is:
    """
    @invalid_token;
    """
    When the scanner is run
    Then an error should be raised indicating an invalid token was encountered