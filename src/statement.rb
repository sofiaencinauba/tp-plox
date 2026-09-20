require_relative 'ast_node'

class AST
  class VarDeclaration < Statement
    attr_reader :name, :initializer

    def initialize(name, initializer = nil)
      @name = name
      @initializer = initializer
    end

    def to_s
      "VarDeclaration: #{@name} = #{@initializer}"
    end
  end

  class FunctionDeclaration < Statement
    attr_reader :name, :params, :body

    def initialize(name, params, body)
      @name = name
      @params = params
      @body = body
    end

    def to_s
      "FunctionDeclaration: #{@name}(#{@params.join(', ')}) { #{@body} }"
    end
  end

  class ExpressionStatement < Statement
    attr_reader :expression

    def initialize(expression)
      @expression = expression
    end

    def to_s
      "ExpressionStatement: #{@expression}"
    end
  end

  class PrintStatement < Statement
    attr_reader :expression

    def initialize(expression)
      @expression = expression
    end

    def to_s
      "PrintStatement: #{@expression}"
    end
  end

  class BlockStatement < Statement
    attr_reader :statements

    def initialize(statements)
      @statements = statements
    end

    def to_s
      "BlockStatement: { #{@statements.map(&:to_s).join('; ')} }"
    end
  end

  class ReturnStatement < Statement
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_s
      "ReturnStatement: return #{@value}"
    end
  end

  class IfStatement < Statement
    attr_reader :condition, :then_branch, :else_branch

    def initialize(condition, then_branch, else_branch)
      @condition = condition
      @then_branch = then_branch
      @else_branch = else_branch
    end

    def to_s
      "IfStatement: if #{@condition} then #{@then_branch} else #{@else_branch}"
    end
  end

  class WhileStatement < Statement
    attr_reader :condition, :body

    def initialize(condition, body)
      @condition = condition
      @body = body
    end

    def to_s
      "WhileStatement: while #{@condition} do #{@body}"
    end
  end

  class ForStatement < Statement
    attr_reader :initializer, :condition, :increment, :body

    def initialize(initializer, condition, increment, body)
      @initializer = initializer
      @condition = condition
      @increment = increment
      @body = body
    end

    def to_s
      "ForStatement: for #{@initializer}; #{@condition}; #{@increment} do #{@body}"
    end
  end
end
