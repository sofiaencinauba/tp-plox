require_relative 'ast_node'

class AST
  class Literal < Expression
    attr_reader :value

    def initialize(value)
      @value = value
    end
  end

  class Variable < Expression
    attr_reader :name

    def initialize(name)
      @name = name.lexeme
    end
  end

  class Grouping < Expression
    attr_reader :expression

    def initialize(expression)
      @expression = expression
    end
  end

  class Unary < Expression
    attr_reader :operator, :right

    def initialize(operator, right)
      @operator = operator
      @right = right
    end
  end

  class Binary < Expression
    attr_reader :left, :operator, :right

    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end
  end

  class Logical < Expression
    attr_reader :left, :operator, :right

    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end
  end

  class Assignment < Expression
    attr_reader :name, :operator, :value

    def initialize(name, operator, value)
      @name = name.name
      @operator = operator
      @value = value
    end
  end
end
