Feature: Interpreter

  Scenario: Evaluate an arithmetic expression
    Given the interpreter program "print 1 + 2 * 3;"
    When the interpreter runs the program
    Then the interpreter output should be:
      """
      7.0
    
      """

  Scenario: Execute the selected conditional branch
    Given the interpreter program "if (false) print \"then\"; else print \"else\";"
    When the interpreter runs the program
    Then the interpreter output should be:
      """
      else

      """

  Scenario: Keep variables in their scopes
    Given the interpreter program "var a = \"global\"; { var a = \"local\"; print a; } print a;"
    When the interpreter runs the program
    Then the interpreter output should be:
      """
      local
      global
      
      """
