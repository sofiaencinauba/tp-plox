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
  end
end