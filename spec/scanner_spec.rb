require 'spec_helper'
require_relative '../src/scanner'
require_relative '../src/token'

RSpec.describe Scanner do
  describe '#scan' do
    describe 'scan_single_token' do
      it 'devuelve una lista vacía para una fuente vacía' do
        expect(Scanner.new('').scan).to eq([])
      end
      it 'devuelve un signo de exclamación para una fuente con signo de exclamación' do
        expect(Scanner.new('!').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :bang, lexeme: nil, literal: nil)))
      end
      it 'devuelve un parentesis derecho para una fuente con parentesis derecho' do
        expect(Scanner.new(')').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :right_paren, lexeme: nil, literal: nil)))
      end
      it 'devuelve un punto y coma para una fuente con punto y coma' do
        expect(Scanner.new(';').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :semicolon, lexeme: nil, literal: nil)))
      end
    end

    describe 'scan_digit' do
      it 'devuelve un número para una fuente con un número' do
        expect(Scanner.new('1').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :number, lexeme: "1", literal: nil)))
      end
      it 'devuelve un numero de 3 digitos para una fuente con numero de 3 digitos' do
        expect(Scanner.new('123').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :number, lexeme: "123", literal: nil)))
      end
    end

    describe 'scan_double_token' do
      it 'devuelve un signo de desigualdad para una fuente con signo de desigualdad' do
        expect(Scanner.new('!=').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :bang_equal, lexeme: nil, literal: nil)))
      end
      it 'devuelve un signo de igualdad para una fuente con signo de igualdad' do
        expect(Scanner.new('==').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :equal_equal, lexeme: nil, literal: nil)))
      end
      it 'devuelve un signo de menor o igual para una fuente con signo de menor o igual' do
        expect(Scanner.new('<=').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :less_equal, lexeme: nil, literal: nil)))
      end
      it 'devuelve un signo de mayor o igual para una fuente con signo de mayor o igual' do
        expect(Scanner.new('>=').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :greater_equal, lexeme: nil, literal: nil)))
      end
    end

    describe 'scan_string' do
      it 'devuelve un string para una fuente con un string' do
        expect(Scanner.new('"hola"').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :string, lexeme: 'hola', literal: nil)))
      end
    end
    
    describe 'scan_identifier' do
      it 'devuelve un identificador para una fuente con string no reservado' do
        expect(Scanner.new('x').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :identifier, lexeme: 'x', literal: nil)))
      end
      it 'devuelve un identificador para una fuente con string no reservado' do
        expect(Scanner.new('xyz').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :identifier, lexeme: 'xyz', literal: nil)))
      end
      it 'devuelve un identificador para una fuente con string no reservado' do
        expect(Scanner.new('x_yz').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :identifier, lexeme: 'x_yz', literal: nil)))
      end
    end

    describe 'scan_unexpected_character' do
      it 'lanza un error para una fuente con un caracter inesperado' do
        expect { Scanner.new('@').scan }.to raise_error(Scanner::Error, 'Unexpected character: @')
      end
    end
  end
end
