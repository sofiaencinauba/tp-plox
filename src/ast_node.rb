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

  class Printer
    def print(node)
      case node
      when AST::Literal
        "<#{literal_value(node.value)}>"
      when AST::Variable
        "<#{node.name}>"
      when AST::Grouping
        "(#{print(node.expression)})"
      when AST::Unary
        "(#{operator_name(node.operator)} #{print(node.right)})"
      when AST::Binary
        "(#{print(node.left)} #{operator_name(node.operator)} #{print(node.right)})"
      when AST::Logical
        "(#{print(node.left)} #{operator_name(node.operator)} #{print(node.right)})"
      when AST::Assignment
        "#{node.name} #{node.operator.lexeme} #{print(node.value)}"
      when AST::Call
        "fn<#{print(node.callee)}(#{node.arguments.map { |argument| print(argument) }.join(', ')})>"
      when AST::ExpressionStatement
        print(node.expression)
      when AST::Program
        node.statements.map { |statement| print(statement) }.join('; ')
      when AST::VarDeclaration
        "VAR #{identifier_name(node.name)} = #{node.initializer ? print(node.initializer) : 'NIL'}"
      when AST::PrintStatement
        "PRINT #{print(node.expression)}"
      when AST::BlockStatement
        "{ #{node.statements.map { |statement| print(statement) }.join('; ')} }"
      when AST::ReturnStatement
        "RETURN #{print(node.value)}"
      when AST::IfStatement
        result = "IF #{print(node.condition)} THEN #{print(node.then_branch)}"
        node.else_branch ? "#{result} ELSE #{print(node.else_branch)}" : result
      when AST::WhileStatement
        "WHILE #{print(node.condition)} #{print(node.body)}"
      when AST::ForStatement
          body = "{ #{print(node.body)}; #{print(node.increment)} }"
          "{ #{print(node.initializer)}; WHILE #{print(node.condition)} #{body} }"
      when AST::FunctionDeclaration
        parameters = node.params.map { |parameter| identifier_name(parameter) }.join(', ')
        "FUN fn<#{identifier_name(node.name)}(#{parameters})> #{print(node.body)}"
      else
        node.inspect
      end
    end

    private

    def operator_name(operator)
      operator.token_type.to_s.upcase
    end

    def identifier_name(identifier)
      identifier.respond_to?(:lexeme) ? identifier.lexeme : identifier
    end

    def literal_value(value)
      return 'TRUE' if value == true
      return 'FALSE' if value == false
      return 'NIL' if value.nil?

      value
    end
  end
end
