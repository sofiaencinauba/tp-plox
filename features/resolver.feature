Feature: Resolver

  Scenario: Resolve a valid program
    Given the resolver program "var a = \"global\"; { print a; }"
    When the resolver runs the program
    Then the resolver should report success

  Scenario: Reject a local variable in its own initializer
    Given the resolver program "{ var a = a; }"
    When the resolver runs the program
    Then the resolver should report the error "propio inicializador"
