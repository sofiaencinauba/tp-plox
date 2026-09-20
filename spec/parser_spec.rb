require 'spec_helper'
require_relative '../src/scanner'
require_relative '../src/parser'

RSpec.describe Parser do
  def parse_program(source)
    Parser.new(Scanner.new(source).scan).parse
  end

  def parse_expression(source)
    parse_program("#{source};").statements.first
  end

  describe '#parse program' do
    it 'devuelve un programa vacío para una fuente vacía' do
      expect(parse_program('')).to eq(AST::Program.new([]))
    end

    it 'incluye cada expresión como un nodo del programa' do
      program = parse_program('1; 2;')

      expect(program.statements).to eq([AST::Literal.new(1.0), AST::Literal.new(2.0)])
    end

    it 'requiere punto y coma al final de cada instrucción' do
      expect { parse_program('print 1') }.to raise_error(Parser::Error, /Se esperaba ';'/)
      expect { parse_program('1 print 2;') }.to raise_error(Parser::Error, /Se esperaba ';'/)
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
      expect(program.statements.last.expression.name.lexeme).to eq('a')
    end

    it 'rechaza una declaración sin nombre y print sin expresión' do
      expect { parse_program('var;') }.to raise_error(Parser::Error, /nombre de variable/)
      expect { parse_program('print;') }.to raise_error(Parser::Error, /Se esperaba una expresión/)
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
end
