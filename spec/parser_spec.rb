require 'spec_helper'
require_relative '../src/scanner'
require_relative '../src/parser'

RSpec.describe Parser do
  def parse_program(source)
    Parser.new(Scanner.new(source).scan).parse
  end

  def parse_expression(source)
    parse_program("#{source};").statements.first.expression
  end

  describe '#parse program' do
    it 'devuelve un programa vacío para una fuente vacía' do
      expect(parse_program('')).to eq(AST::Program.new([]))
    end

    it 'incluye cada expresión como un nodo del programa' do
      program = parse_program('1; 2;')

      expect(program.statements).to eq(
        [AST::ExpressionStatement.new(AST::Literal.new(1.0)), AST::ExpressionStatement.new(AST::Literal.new(2.0))]
      )
    end

    it 'requiere punto y coma al final de una instrucción libre' do
      expect { parse_program('print 1') }.to raise_error(Parser::Error, /Se esperaba ';'/)
      expect { parse_program('1 print 2;') }.to raise_error(Parser::Error, /Se esperaba ';'/)
    end

    it 'permite omitir el punto y coma antes de cerrar un bloque o una rama else' do
      expect { parse_program('if (true) { print "ok" }') }.not_to raise_error
    end
  end

  describe '#parse var y print' do
    it 'parsea una declaración sin inicializador' do
      declaration = parse_program('var nombre;').statements.first

      expect(declaration).to be_a(AST::VarDeclaration)
      expect(declaration.name.lexeme).to eq('nombre')
      expect(declaration.initializer).to be_nil
    end

    it 'parsea el inicializador como expresión' do
      declaration = parse_program('var total = 1 + 2;').statements.first

      expect(declaration).to be_a(AST::VarDeclaration)
      expect(declaration.name.lexeme).to eq('total')
      expect(declaration.initializer).to be_a(AST::Binary)
      expect(declaration.initializer.operator.token_type).to eq(TokenType::PLUS)
    end

    it 'parsea print con una expresión' do
      statement = parse_program('print 1 + 2;').statements.first

      expect(statement).to be_a(AST::PrintStatement)
      expect(statement.expression).to be_a(AST::Binary)
      expect(statement.expression.operator.token_type).to eq(TokenType::PLUS)
    end

    it 'conserva el orden de declaraciones y print' do
      program = parse_program('var a = 1; print a;')

      expect(program.statements.map(&:class)).to eq([AST::VarDeclaration, AST::PrintStatement])
      expect(program.statements.last.expression.name).to eq('a')
    end

    it 'rechaza una declaración sin nombre y print sin expresión' do
      expect { parse_program('var;') }.to raise_error(Parser::Error, /nombre de variable/)
      expect { parse_program('print;') }.to raise_error(Parser::Error, /Se esperaba una expresión/)
    end
  end

  describe '#parse function declarations' do
    it 'parsea una función sin parámetros' do
      declaration = parse_program('fun saludar() { print "hola"; };').statements.first

      expect(declaration).to be_a(AST::FunctionDeclaration)
      expect(declaration.name.lexeme).to eq('saludar')
      expect(declaration.params).to be_empty
      expect(declaration.body).to be_a(AST::BlockStatement)
    end

    it 'parsea los parámetros de una función' do
      declaration = parse_program('fun sumar(a, b) { print a + b; };').statements.first

      expect(declaration.params.map(&:lexeme)).to eq(%w[a b])
      expect(declaration.body.statements.first).to be_a(AST::PrintStatement)
    end
  end

  describe '#parse if' do
    it 'parsea condición y rama then sin else' do
      statement = parse_program('if (1 < 2) print "si";').statements.first

      expect(statement).to be_a(AST::IfStatement)
      expect(statement.condition).to be_a(AST::Binary)
      expect(statement.condition.operator.token_type).to eq(TokenType::LESS)
      expect(statement.then_branch).to be_a(AST::PrintStatement)
      expect(statement.else_branch).to be_nil
    end

    it 'parsea las dos ramas' do
      statement = parse_program('if (true) print "si" else print "no";').statements.first

      expect(statement.then_branch.expression).to eq(AST::Literal.new('si'))
      expect(statement.else_branch.expression).to eq(AST::Literal.new('no'))
    end

    it 'asocia else con el if más cercano' do
      outer = parse_program('if (true) if (false) print 1 else print 2;').statements.first

      expect(outer.else_branch).to be_nil
      expect(outer.then_branch).to be_a(AST::IfStatement)
      expect(outer.then_branch.else_branch).to be_a(AST::PrintStatement)
    end

    it 'rechaza paréntesis faltantes en la condición' do
      expect { parse_program('if true) print 1;') }.to raise_error(Parser::Error, /después de if/)
      expect { parse_program('if (true print 1;') }.to raise_error(Parser::Error, /después de la condición/)
    end
  end

  describe '#parse literals' do
    it 'parsea un número como literal' do
      expect(parse_expression('1')).to eq(AST::Literal.new(1.0))
    end

    it 'parsea un string como literal' do
      expect(parse_expression('"hola"')).to eq(AST::Literal.new('hola'))
    end

    it 'parsea true' do
      expect(parse_expression('true')).to eq(AST::Literal.new(true))
    end

    it 'parsea false' do
      expect(parse_expression('false')).to eq(AST::Literal.new(false))
    end

    it 'parsea nil' do
      expect(parse_expression('nil')).to eq(AST::Literal.new(nil))
    end
  end

  describe '#parse unary expressions' do
    it 'parsea una negación lógica' do
      resultado = parse_expression('!true')

      expect(resultado).to be_a(AST::Unary)
      expect(resultado.operator.token_type).to eq(:bang)
      expect(resultado.right).to eq(AST::Literal.new(true))
    end

    it 'parsea una negación aritmética' do
      resultado = parse_expression('-1')

      expect(resultado).to be_a(AST::Unary)
      expect(resultado.operator.token_type).to eq(:minus)
      expect(resultado.right).to eq(AST::Literal.new(1.0))
    end

    it 'anida unarios a derecha' do
      resultado = parse_expression('!!true')

      expect(resultado).to be_a(AST::Unary)
      expect(resultado.right).to be_a(AST::Unary)
      expect(resultado.right.right).to eq(AST::Literal.new(true))
    end
  end

  describe '#parse binary expressions' do
    it 'parsea una suma' do
      result = parse_expression('1 + 2')

      expect(result).to be_a(AST::Binary)
      expect(result.operator.token_type).to eq(:plus)
      expect(result.left).to eq(AST::Literal.new(1.0))
      expect(result.right).to eq(AST::Literal.new(2.0))
    end

    it 'da mayor precedencia a la multiplicación' do
      result = parse_expression('1 + 2 * 3')

      expect(result.operator.token_type).to eq(:plus)
      expect(result.left).to eq(AST::Literal.new(1.0))

      expect(result.right).to be_a(AST::Binary)
      expect(result.right.operator.token_type).to eq(:star)
      expect(result.right.left).to eq(AST::Literal.new(2.0))
      expect(result.right.right).to eq(AST::Literal.new(3.0))
    end

    it 'agrupa restas hacia la izquierda' do
      result = parse_expression('1 - 2 - 3')

      expect(result.operator.token_type).to eq(:minus)
      expect(result.right).to eq(AST::Literal.new(3.0))

      expect(result.left).to be_a(AST::Binary)
      expect(result.left.operator.token_type).to eq(:minus)
      expect(result.left.left).to eq(AST::Literal.new(1.0))
      expect(result.left.right).to eq(AST::Literal.new(2.0))
    end

    it 'respeta la precedencia entre comparación e igualdad' do
      result = parse_expression('1 < 2 == true')

      expect(result.operator.token_type).to eq(:equal_equal)
      expect(result.left).to be_a(AST::Binary)
      expect(result.left.operator.token_type).to eq(:less)
      expect(result.right).to eq(AST::Literal.new(true))
    end

    it 'usa paréntesis para cambiar la precedencia' do
      result = parse_expression('(1 + 2) * 3')

      expect(result.operator.token_type).to eq(:star)
      expect(result.left).to be_a(AST::Grouping)
      expect(result.left.expression.operator.token_type).to eq(:plus)
      expect(result.right).to eq(AST::Literal.new(3.0))
    end

    it 'falla cuando falta cerrar un paréntesis' do
      expect { parse_expression('(1 + 2') }
        .to raise_error(Parser::Error, /paréntesis de cierre/)
    end
  end

  describe '#parse logical expressions' do
    it 'parsea logica de AND' do
      result = parse_expression('true and false')

      expect(result).to be_a(AST::Logical)
      expect(result.operator.token_type).to eq(:and)
      expect(result.left).to eq(AST::Literal.new(true))
      expect(result.right).to eq(AST::Literal.new(false))
    end

    it 'parsea logica de OR' do
      result = parse_expression('true or false')

      expect(result).to be_a(AST::Logical)
      expect(result.operator.token_type).to eq(:or)
      expect(result.left).to eq(AST::Literal.new(true))
      expect(result.right).to eq(AST::Literal.new(false))
    end
  end

  describe '#parse call expressions' do
    it 'parsea una llamada con argumentos' do
      result = parse_expression('sumar(1, 2)')

      expect(result).to be_a(AST::Call)
      expect(result.callee).to eq(AST::Variable.new(Token.new(TokenType::IDENTIFIER, 'sumar')))
      expect(result.arguments).to eq([AST::Literal.new(1.0), AST::Literal.new(2.0)])
    end

    it 'parsea una llamada sin argumentos' do
      result = parse_expression('saludar()')

      expect(result).to be_a(AST::Call)
      expect(result.arguments).to be_empty
    end

    it 'rechaza una llamada sin cerrar paréntesis' do
      expect { parse_expression('sumar(1') }
        .to raise_error(Parser::Error, /Se esperaba '\)' después de los argumentos/)
    end
  end

  describe '#parse assignment expressions' do
    it 'parsea una asignación simple' do
      result = parse_expression('a = 1')

      expect(result).to be_a(AST::Assignment)
      expect(result.name).to eq('a')
      expect(result.value).to eq(AST::Literal.new(1.0))
    end

    it 'rechaza una asignación sin nombre de variable' do
      expect { parse_expression('= 1') }.to raise_error(Parser::Error, /nombre de variable/)
    end

    it 'rechaza una asignación a un literal' do
      expect { parse_expression('1 = 2') }.to raise_error(Parser::Error, /nombre de variable/)
    end

    it 'rechaza una asignación a una expresión' do
      expect { parse_expression('(a + b) = 1') }.to raise_error(Parser::Error, /nombre de variable/)
    end

    it 'rechaza una asignación sin valor' do
      expect { parse_expression('a =') }.to raise_error(Parser::Error, /Se esperaba una expresión/)
    end
  end
end
