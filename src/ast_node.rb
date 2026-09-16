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
end

# module AST
#   Literal  = Struct.new(:value)
#   Grouping = Struct.new(:expression)
#   Unary    = Struct.new(:operator, :right)
#   Binary   = Struct.new(:left, :operator, :right)
# end

# class ASTPrinter
#   def print(expression)
#     case expression
#     when AST::Literal
#       print_literal(expression)
#     when AST::Grouping
#       "(#{print(expression.expression)})"
#     when AST::Unary
#       "(#{operator_name(expression.operator)} #{print(expression.right)})"
#     when AST::Binary
#       left = print(expression.left)
#       right = print(expression.right)
#       operator = operator_name(expression.operator)

#       "(#{left} #{operator} #{right})"
#     else
#       raise ArgumentError, "Nodo desconocido: #{expression.class}"
#     end
#   end

#   private

#   def print_literal(expression)
#     "<#{expression.value.inspect}>"
#   end

#   def operator_name(operator)
#     operator.token_type.to_s.upcase
#   end
# end
