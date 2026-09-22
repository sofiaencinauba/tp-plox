require 'spec_helper'
require_relative '../src/function'
require_relative '../src/token'
require_relative '../src/expression'
require_relative '../src/statement'

RSpec.describe Function do
  def token(lexeme)
    Token.new(TokenType::IDENTIFIER, lexeme)
  end

  def declaration(name, parameters)
    AST::FunctionDeclaration.new(
      token(name),
      parameters.map { |parameter| AST::VarDeclaration.new(token(parameter)) },
      AST::BlockStatement.new([])
    )
  end

  it 'representa el nombre y los parámetros de la función' do
    function_declaration = declaration('sumar', %w[a b])

    function = described_class.new(function_declaration, Env.new)

    expect(function.represent).to eq('fn sumar(a, b)')
    expect(function.to_s).to eq('fn sumar(a, b)')
  end

  it 'crea un entorno con los argumentos y el closure' do
    closure = Env.new
    closure.define('externa', 10.0)
    function_declaration = declaration('sumar', ['a'])
    function = described_class.new(function_declaration, closure)
    captured_environment = nil
    interpreter = instance_double('Interpreter')

    allow(interpreter).to receive(:execute_block) do |_statements, environment|
      captured_environment = environment
      :result
    end

    expect(function.call(interpreter, [2.0])).to eq(:result)
    expect(captured_environment.get('a')).to eq(2.0)
    expect(captured_environment.get('externa')).to eq(10.0)
  end
end