require_relative 'env'

class Function
  def initialize(declaration, closure_environment)
    @declaration = declaration
    @closure_environment = closure_environment
  end

  def call(interpreter, arguments)
    expected = @declaration.params.length
    unless arguments.length == expected
      raise ArgumentError, "Se esperaban #{expected} argumentos, se recibieron #{arguments.length}."
    end

    environment = Env.new(@closure_environment)
    @declaration.params.each_with_index do |param, index|
      environment.define(param.lexeme, arguments[index])
    end
    interpreter.execute_block(@declaration.body.statements, environment)
  end

  def arity
    @declaration.params.length
  end

  def represent
    params = @declaration.params.map(&:lexeme).join(', ')
    "fn #{@declaration.name.lexeme}(#{params})"
  end

  alias to_s represent
end