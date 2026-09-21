class AST
  class Node
    def ==(other)
      other.class == self.class && other.instance_variables.all? do |variable|
        instance_variable_get(variable) == other.instance_variable_get(variable)
      end
    end

    alias eql? ==

    def hash
      [self.class, *instance_variables.map { |variable| instance_variable_get(variable) }].hash
    end

    def inspect
      attributes = instance_variables.map do |variable|
        value = instance_variable_get(variable)
        "#{variable}=#{value.inspect}"
      end

      "#{self.class.name}(#{attributes.join(', ')})"
    end
  end

  class Expression < Node
  end

  class Statement < Node
  end

  class Program < Node
    attr_reader :statements

    def initialize(statements)
      @statements = statements
    end
  end

  class ExpressionStatement < Statement
    attr_reader :expression

    def initialize(expression)
      @expression = expression
    end
  end
end
