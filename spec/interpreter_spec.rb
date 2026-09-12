require 'spec_helper'
require_relative '../src/scanner'
require_relative '../src/parser'
require_relative '../src/interpreter'

RSpec.describe Interpreter do
  def interpret(source)
    expression = Parser.new(Scanner.new(source).scan).parse
    described_class.new.interpret(expression)
  end

  it 'respeta la precedencia entre suma y multiplicación' do
    expect { interpret('1 + 2 * 3') }.to output("7.0\n").to_stdout
  end

  it 'evalúa primero una expresión agrupada' do
    expect { interpret('(1 + 2) * 3') }.to output("9.0\n").to_stdout
  end

  it 'evalúa la negación aritmética' do
    expect { interpret('-5') }.to output("-5.0\n").to_stdout
  end

  it 'considera nil como falso' do
    expect { interpret('!nil') }.to output("true\n").to_stdout
  end

  it 'considera un string como verdadero' do
    expect { interpret('!"hola"') }.to output("false\n").to_stdout
  end

  it 'compara valores de distinto tipo como diferentes' do
    expect { interpret('1 == "1"') }.to output("false\n").to_stdout
  end

  it 'considera dos valores nil como iguales' do
    expect { interpret('nil == nil') }.to output("true\n").to_stdout
  end

  it 'compara correctamente dos negaciones de nil' do
    expect { interpret('!nil == !nil') }.to output("true\n").to_stdout
  end

  it 'considera falso que nil sea diferente de nil' do
    expect { interpret('nil != nil') }.to output("false\n").to_stdout
  end

  it 'concatena dos strings' do
    expect { interpret('"a" + "b"') }.to output("ab\n").to_stdout
  end

  it 'rechaza la suma de un string y un número' do
    expect { interpret('"a" + 1') }
      .to raise_error(
        Interpreter::Error,
        'Se esperaba que ambos operandos fueran números o strings, se encontró String y Float.'
      )
  end

  it 'rechaza la comparación de dos strings' do
    expect { interpret('"a" < "b"') }
      .to raise_error(
        Interpreter::Error,
        'Se esperaba que ambos operandos fueran números, se encontró String y String.'
      )
  end
end
