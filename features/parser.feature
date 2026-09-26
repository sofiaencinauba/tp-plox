Feature: Parser

  Scenario: Parse a simple expression
    Given the input "1;"
    When I parse the expression
    Then the result should be "<1.0>"

  Scenario: Parse a complex expression
    Given the input "1 + 2;"
    When I parse the expression
    Then the result should be "(<1.0> PLUS <2.0>)"
  
  Scenario: Parse a unary expression
    Given the input "-1;"
    When I parse the expression
    Then the result should be "(MINUS <1.0>)"

  Scenario: Parse a variable declaration
    Given the input "var x = 42;"
    When I parse the expression
    Then the result should be "VAR x = <42.0>"
  
  Scenario: Parse a function declaration
    Given the input "fun add(a, b) { return a + b; }"
    When I parse the expression
    Then the result should be "FUN fn<add(a, b)> { RETURN (<a> PLUS <b>) }"
  
  Scenario: Parse a function call
    Given the input "add(1, 2);"
    When I parse the expression
    Then the result should be "fn<<add>(<1.0>, <2.0>)>"
  
  Scenario: Parse a simple statement
    Given the input "print 1;"
    When I parse the expression
    Then the result should be "PRINT <1.0>"
  
  Scenario: Parse a compound statement
    Given the input "{ print 1; print 2; }"
    When I parse the expression
    Then the result should be "{ PRINT <1.0>; PRINT <2.0> }"
  
  Scenario: Parse a conditional statement
    Given the input "if (true) { print 1; } else { print 2; }"
    When I parse the expression
    Then the result should be "IF <TRUE> THEN { PRINT <1.0> } ELSE { PRINT <2.0> }"
  
  Scenario: Parse a while loop
    Given the input "while (true) { print 1; }"
    When I parse the expression
    Then the result should be "WHILE <TRUE> { PRINT <1.0> }"
  
  Scenario: Parse a for loop
    Given the input "for (var i = 0; i < 10; i = i + 1) { print i; }"
    When I parse the expression
    Then the result should be "{ VAR i = <0.0>; WHILE (<i> LESS <10.0>) { { PRINT <i> }; i = (<i> PLUS <1.0>) } }"
  
  Scenario: Parse an invalid expression
    Given the input "1 + ;"
    When I parse the expression
    Then an error should be raised with message "Unexpected token: SEMICOLON"
