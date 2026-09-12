require 'spec_helper'
require_relative '../src/scanner'
require_relative '../src/parser'

RSpec.describe Parser do
  def parse(source)
    Parser.new(Scanner.new(source).scan).parse
  end

  describe '#parse literals' do
    it 'parsea un número como literal' do
      expect(parse('1')).to eq(AST::Literal.new(1.0))
    end

    it 'parsea un string como literal' do
      expect(parse('"hola"')).to eq(AST::Literal.new('hola'))
    end

    it 'parsea true' do
      expect(parse('true')).to eq(AST::Literal.new(true))
    end

    it 'parsea false' do
      expect(parse('false')).to eq(AST::Literal.new(false))
    end

    it 'parsea nil' do
      expect(parse('nil')).to eq(AST::Literal.new(nil))
    end
  end

  describe '#parse unary expressions' do
    it 'parsea una negación lógica' do
      resultado = parse('!true')

      expect(resultado).to be_a(AST::Unary)
      expect(resultado.operator.token_type).to eq(:bang)
      expect(resultado.right).to eq(AST::Literal.new(true))
    end

    it 'parsea una negación aritmética' do
      resultado = parse('-1')

      expect(resultado).to be_a(AST::Unary)
      expect(resultado.operator.token_type).to eq(:minus)
      expect(resultado.right).to eq(AST::Literal.new(1.0))
    end

    it 'anida unarios a derecha' do
      resultado = parse('!!true')

      expect(resultado).to be_a(AST::Unary)
      expect(resultado.right).to be_a(AST::Unary)
      expect(resultado.right.right).to eq(AST::Literal.new(true))
    end
  end

  describe '#parse binary expressions' do
    it 'parsea una suma' do
      result = parse('1 + 2')

      expect(result).to be_a(AST::Binary)
      expect(result.operator.token_type).to eq(:plus)
      expect(result.left).to eq(AST::Literal.new(1.0))
      expect(result.right).to eq(AST::Literal.new(2.0))
    end

    it 'da mayor precedencia a la multiplicación' do
      result = parse('1 + 2 * 3')

      expect(result.operator.token_type).to eq(:plus)
      expect(result.left).to eq(AST::Literal.new(1.0))

      expect(result.right).to be_a(AST::Binary)
      expect(result.right.operator.token_type).to eq(:star)
      expect(result.right.left).to eq(AST::Literal.new(2.0))
      expect(result.right.right).to eq(AST::Literal.new(3.0))
    end

    it 'agrupa restas hacia la izquierda' do
      result = parse('1 - 2 - 3')

      expect(result.operator.token_type).to eq(:minus)
      expect(result.right).to eq(AST::Literal.new(3.0))

      expect(result.left).to be_a(AST::Binary)
      expect(result.left.operator.token_type).to eq(:minus)
      expect(result.left.left).to eq(AST::Literal.new(1.0))
      expect(result.left.right).to eq(AST::Literal.new(2.0))
    end

    it 'parsea una entrada vacía como nil' do
      expect(parse('')).to eq(AST::Literal.new(nil))
    end

    it 'respeta la precedencia entre comparación e igualdad' do
      result = parse('1 < 2 == true')

      expect(result.operator.token_type).to eq(:equal_equal)
      expect(result.left).to be_a(AST::Binary)
      expect(result.left.operator.token_type).to eq(:less)
      expect(result.right).to eq(AST::Literal.new(true))
    end

    it 'usa paréntesis para cambiar la precedencia' do
      result = parse('(1 + 2) * 3')

      expect(result.operator.token_type).to eq(:star)
      expect(result.left).to be_a(AST::Grouping)
      expect(result.left.expression.operator.token_type).to eq(:plus)
      expect(result.right).to eq(AST::Literal.new(3.0))
    end

    it 'falla cuando falta cerrar un paréntesis' do
      expect { parse('(1 + 2') }
        .to raise_error(Parser::Error, /paréntesis de cierre/)
    end
  end
end
