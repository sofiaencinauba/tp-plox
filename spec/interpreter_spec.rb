require 'spec_helper'
require_relative '../src/scanner'
require_relative '../src/parser'
require_relative '../src/interpreter'
require_relative '../src/resolver'

RSpec.describe Interpreter do
  let(:interpreter) { described_class.new }
  let(:resolver) { Resolver.new(interpreter) }

  def parse_program(source)
    Parser.new(Scanner.new(source).scan).parse
  end

  def run_program(program, interpreter:, resolver:)
    resolver.resolve(program)
    interpreter.interpret(program)
  end

  def interpret(source)
    program = parse_program(source)
    result = run_program(program, interpreter: interpreter, resolver: resolver)
    puts result if program.statements.last.is_a?(AST::ExpressionStatement)
  end

  it 'no produce salida para un programa vacío' do
    expect { interpret('') }.not_to output.to_stdout
  end

  it 'declara una variable sin producir salida' do
    environment = Env.new
    interpreter = described_class.new(environment)

    expect { run_program(parse_program('var a = 1;'), interpreter: interpreter, resolver: Resolver.new(interpreter)) }.not_to output.to_stdout
    expect(environment.get('a')).to eq(1.0)
  end

  it 'define una variable sin inicializador con valor nil' do
    environment = Env.new
    interpreter = described_class.new(environment)

    run_program(parse_program('var a;'), interpreter: interpreter, resolver: Resolver.new(interpreter))

    expect(environment.get('a')).to be_nil
  end

  it 'ejecuta declaraciones y print en orden' do
    expect { interpret('var a = 1; var b = 2; print a + b;') }.to output("3.0\n").to_stdout
  end

  it 'lee una variable de un programa anterior con el mismo intérprete' do
    interpreter = described_class.new
    resolver = Resolver.new(interpreter)

    run_program(parse_program('var a = 1;'), interpreter: interpreter, resolver: resolver)

    expect { run_program(parse_program('print a;'), interpreter: interpreter, resolver: resolver) }
      .to output("1.0\n").to_stdout
  end

  describe 'scopes de bloques' do
    it 'lee variables declaradas en el entorno exterior' do
      expect { interpret('var a = 1; { print a; }') }.to output("1.0\n").to_stdout
    end

    it 'lee variables declaradas en el entorno exterior con doble llave' do
      expect { interpret('var a = 1; {{ print a; } }') }.to output("1.0\n").to_stdout
    end

    it 'permite sombrear una variable sin cambiar su valor exterior' do
      source = 'var a = "global"; { var a = "local"; print a; } print a;'

      expect { interpret(source) }.to output("local\nglobal\n").to_stdout
    end

    it 'no deja acceder desde fuera a una variable local' do
      expect { interpret('{ var a = 1; } print a;') }
        .to raise_error(Env::Error, "Variable 'a' no definida.")
    end

    it 'permite que un bloque anidado lea una variable de su bloque padre' do
      expect { interpret('{ var a = 1; { print a; } }') }.to output("1.0\n").to_stdout
    end

    it 'restaura el entorno anterior aunque una instrucción del bloque falle' do
      interpreter = described_class.new
      resolver = Resolver.new(interpreter)
      run_program(parse_program('var a = "global";'), interpreter: interpreter, resolver: resolver)

      expect do
        run_program(parse_program('{ var a = "local"; print desconocida; }'), interpreter: interpreter, resolver: resolver)
      end.to raise_error(Env::Error, "Variable 'desconocida' no definida.")
      expect { run_program(parse_program('print a;'), interpreter: interpreter, resolver: resolver) }
        .to output("global\n").to_stdout
    end
  end

  describe 'if' do
    it 'ejecuta la rama then cuando la condición es verdadera' do
      expect { interpret('if (true) print "then";') }.to output("then\n").to_stdout
    end

    it 'no ejecuta la rama then cuando la condición es falsa y no hay else' do
      expect { interpret('if (false) print "then";') }.not_to output.to_stdout
    end

    it 'ejecuta la rama else cuando la condición es falsa' do
      expect { interpret('if (false) print "then"; else print "else";') }.to output("else\n").to_stdout
    end

    it 'considera nil falso y otros valores verdaderos' do
      source = 'if (nil) print "then"; else print "else"; if (0) print "numero";'

      expect { interpret(source) }.to output("else\nnumero\n").to_stdout
    end

    it 'evalúa solamente la rama elegida' do
      expect { interpret('if (true) print "ok"; else print desconocida;') }.to output("ok\n").to_stdout
      expect { interpret('if (false) print desconocida; else print "ok";') }.to output("ok\n").to_stdout
    end

    it 'ejecuta un bloque como rama then' do
      expect { interpret('if (true) { var a = 1; print a; }') }.to output("1.0\n").to_stdout
    end

    it 'acepta un bloque sin punto y coma final' do
      expect { interpret('if (true) { print "ok"; }') }.to output("ok\n").to_stdout
    end
  end

  it 'respeta la precedencia entre suma y multiplicación' do
    expect { interpret('1 + 2 * 3;') }.to output("7.0\n").to_stdout
  end

  it 'evalúa primero una expresión agrupada' do
    expect { interpret('(1 + 2) * 3;') }.to output("9.0\n").to_stdout
  end

  it 'evalúa la negación aritmética' do
    expect { interpret('-5;') }.to output("-5.0\n").to_stdout
  end

  it 'considera nil como falso' do
    expect { interpret('!nil;') }.to output("true\n").to_stdout
  end

  it 'considera un string como verdadero' do
    expect { interpret('!"hola";') }.to output("false\n").to_stdout
  end

  it 'compara valores de distinto tipo como diferentes' do
    expect { interpret('1 == "1";') }.to output("false\n").to_stdout
  end

  it 'considera dos valores nil como iguales' do
    expect { interpret('nil == nil;') }.to output("true\n").to_stdout
  end

  it 'compara correctamente dos negaciones de nil' do
    expect { interpret('!nil == !nil;') }.to output("true\n").to_stdout
  end

  it 'considera falso que nil sea diferente de nil' do
    expect { interpret('nil != nil;') }.to output("false\n").to_stdout
  end

  it 'concatena dos strings' do
    expect { interpret('"a" + "b";') }.to output("ab\n").to_stdout
  end

  it 'rechaza la suma de un string y un número' do
    expect { interpret('"a" + 1;') }
      .to raise_error(
        Interpreter::Error,
        'Se esperaba que ambos operandos fueran números o strings, se encontró String y Float.'
      )
  end

  it 'rechaza la comparación de dos strings' do
    expect { interpret('"a" < "b";') }
      .to raise_error(
        Interpreter::Error,
        'Se esperaba que ambos operandos fueran números, se encontró String y String.'
      )
  end

  describe 'expresiones lógicas' do
    it 'evalúa correctamente una expresión lógica AND con dos valores true' do
      expect { interpret('true and true;') }.to output("true\n").to_stdout
    end
    it 'evalúa correctamente una expresión lógica AND con un valor false' do
      expect { interpret('true and false;') }.to output("false\n").to_stdout
    end
    it 'evalúa correctamente una expresión lógica AND con un valor nil' do
      expect { interpret('true and nil;') }.to output("\n").to_stdout
    end
    it 'evalúa correctamente una expresión lógica AND con un valor nil y un valor false' do
      expect { interpret('nil and false;') }.to output("\n").to_stdout
    end
    it 'evalúa correctamente una expresión lógica AND con un valor nil y un valor false' do
      expect { interpret('false and nil;') }.to output("false\n").to_stdout
    end
    it 'evalúa correctamente una expresión lógica OR con dos valores false' do
      expect { interpret('false or false;') }.to output("false\n").to_stdout
    end
    it 'evalúa correctamente una expresión lógica OR con un valor true' do
      expect { interpret('false or true;') }.to output("true\n").to_stdout
    end
    it 'evalúa correctamente una expresión lógica OR con un valor nil y un valor false' do
      expect { interpret('false or nil;') }.to output("\n").to_stdout
    end
    it 'evalúa correctamente una expresión lógica OR con un valor nil y un valor true' do
      expect { interpret('nil or true;') }.to output("true\n").to_stdout
    end
    it 'evalúa correctamente una expresión lógica OR con un valor nil y un valor false' do
      expect { interpret('nil or false;') }.to output("false\n").to_stdout
    end
  end

  describe 'asignación de variables' do
    it 'asigna un valor a una variable existente' do
      environment = Env.new
      interpreter = described_class.new(environment)
      resolver = Resolver.new(interpreter)
      run_program(parse_program('var a = 1;'), interpreter: interpreter, resolver: resolver)
      run_program(parse_program('a = 2;'), interpreter: interpreter, resolver: resolver)

      expect(environment.get('a')).to eq(2.0)
    end

    it 'rechaza la asignación a una variable no declarada' do
      expect { interpret('a = 1;') }.to raise_error(Env::Error, "Variable 'a' no definida.")
    end
  end

  describe 'for' do
    it 'ejecuta inicializador, condición e incremento' do
      source = 'for (var i = 0; i < 3; i = i + 1) print i;'

      expect { interpret(source) }.to output("0.0\n1.0\n2.0\n").to_stdout
    end

    it 'no permite acceder fuera del for a su variable local' do
      source = 'for (var i = 0; i < 1; i = i + 1) { } print i;'

      expect { interpret(source) }
        .to raise_error(Env::Error, "Variable 'i' no definida.")
    end
  end

  describe 'declaraciones de funciones' do
    it 'registra una función en el entorno sin ejecutar su cuerpo' do
      environment = Env.new
      interpreter = described_class.new(environment)
      source = 'fun saludar() { print desconocida; }'

      expect { run_program(parse_program(source), interpreter: interpreter, resolver: Resolver.new(interpreter)) }.not_to raise_error
      expect(environment.get('saludar')).to be_a(Function)
    end

    it 'ejecuta una función con el argumento recibido' do
      source = 'fun prueba(x) { print x; } prueba(2);'
      interpreter = described_class.new

      resolver = Resolver.new(interpreter)
      expect { run_program(parse_program(source), interpreter: interpreter, resolver: resolver) }
        .to output("2.0\n").to_stdout
    end

    it 'retorna un valor desde una función' do
      source = 'fun sumar(a, b) { return a + b; } print sumar(2, 3);'

      expect { interpret(source) }.to output("5.0\n").to_stdout
    end

    it 'sale temprano al encontrar un return' do
      source = 'fun prueba() { print "antes"; return; print "despues"; } prueba();'

      expect { interpret(source) }.to output("antes\n\n").to_stdout
    end

    it 'rechaza llamar a un valor que no es una función' do
      expect { interpret('var numero = 1; numero();') }
        .to raise_error(Interpreter::Error, 'Sólo se pueden llamar funciones.')
    end
  end
end
