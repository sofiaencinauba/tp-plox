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
        expect(Scanner.new('!').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :bang,
                                                                                         lexeme: "!", literal: nil)))
      end
      it 'devuelve un parentesis derecho para una fuente con parentesis derecho' do
        expect(Scanner.new(')').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :right_paren,
                                                                                         lexeme: ")", literal: nil)))
      end
      it 'devuelve un punto y coma para una fuente con punto y coma' do
        expect(Scanner.new(';').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :semicolon,
                                                                                         lexeme: ";", literal: nil)))
      end
    end

    describe 'scan_digit' do
      it 'devuelve un número para una fuente con un número' do
        expect(Scanner.new('1').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :number,
                                                                                         lexeme: '1', literal: 1)))
      end
      it 'devuelve un numero de 3 digitos para una fuente con numero de 3 digitos' do
        expect(Scanner.new('123').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :number,
                                                                                           lexeme: '123', literal: 123)))
      end
      it 'devuelve un numero flotante para una fuente con numero flotante' do
        expect(Scanner.new('123.15').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :number,
                                                                                              lexeme: '123.15', literal: 123.15)))
      end
      it 'lanza un error para un número con más de un punto decimal' do
        expect { Scanner.new('123.10.15').scan }.to raise_error(Scanner::Error, 'Invalid number: 123.10.')
      end
    end

    describe 'scan_double_token' do
      it 'devuelve un signo de desigualdad para una fuente con signo de desigualdad' do
        expect(Scanner.new('!=').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :bang_equal,
                                                                                          lexeme: "!=", literal: nil)))
      end
      it 'devuelve un signo de igualdad para una fuente con signo de igualdad' do
        expect(Scanner.new('==').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :equal_equal,
                                                                                          lexeme: "==", literal: nil)))
      end
      it 'devuelve un signo de menor o igual para una fuente con signo de menor o igual' do
        expect(Scanner.new('<=').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :less_equal,
                                                                                          lexeme: "<=", literal: nil)))
      end
      it 'devuelve un signo de mayor o igual para una fuente con signo de mayor o igual' do
        expect(Scanner.new('>=').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :greater_equal,
                                                                                          lexeme: ">=", literal: nil)))
      end
    end

    describe 'scan_string' do
      it 'devuelve un string para una fuente con un string' do
        expect(Scanner.new('"hola"').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :string,
                                                                                              lexeme: '"hola"', literal: 'hola')))
      end
      it 'devuelve un error para fuente con string incompleto' do
        expect { Scanner.new('"hola').scan }.to raise_error(Scanner::Error, 'Unterminated string.')
      end
    end

    describe 'scan_identifier' do
      it 'devuelve un identificador para una fuente con string no reservado' do
        expect(Scanner.new('x').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :identifier,
                                                                                         lexeme: 'x', literal: nil)))
      end
      it 'devuelve un identificador para una fuente con string no reservado' do
        expect(Scanner.new('xyz').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :identifier,
                                                                                           lexeme: 'xyz', literal: nil)))
      end
      it 'devuelve un identificador para una fuente con string no reservado' do
        expect(Scanner.new('xyz1').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :identifier,
                                                                                           lexeme: 'xyz1', literal: nil)))
      end
      it 'devuelve un identificador para una fuente con string no reservado' do
        expect(Scanner.new('x_yz').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :identifier,
                                                                                            lexeme: 'x_yz', literal: nil)))
      end
      it 'separa un identificador, un punto y un número' do
        expect(Scanner.new('hola.1').scan).to contain_exactly(
          be_a(Token).and(have_attributes(token_type: :identifier, lexeme: 'hola', literal: nil)),
          be_a(Token).and(have_attributes(token_type: :dot, lexeme: '.', literal: nil)),
          be_a(Token).and(have_attributes(token_type: :number, lexeme: '1', literal: 1))
        )
      end
    end
    describe 'scan_comments' do
      it 'devuelve un slash para una fuente con un slash' do
        expect(Scanner.new('/').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :slash,
                                                                                          lexeme: '/', literal: nil)))
      end
      it 'ignora la linea para una fuente con unica linea de comentario' do
        expect(Scanner.new('//').scan).to contain_exactly()
      end
      it 'ignora la linea para una fuente con unica linea de comentario' do
        expect(Scanner.new('//hola').scan).to contain_exactly()
      end
    end
    describe 'scan_keywords' do
      it 'devuelve una keyword para una fuente con un string keyword' do
        expect(Scanner.new('and').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :and,
                                                                                           lexeme: 'and', literal: nil)))
      end
      it 'devuelve una keyword para una fuente con un string keyword' do
        expect(Scanner.new('or').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :or,
                                                                                          lexeme: 'or', literal: nil)))
      end
      it 'no devuelve keyword para una fuente con un string keyword en mayuscula' do
        expect(Scanner.new('AND').scan).to contain_exactly(be_a(Token).and(have_attributes(token_type: :identifier,
                                                                                           lexeme: 'AND', literal: nil)))
      end
    end
    describe 'scan_unexpected_character' do
      it 'lanza un error para una fuente con un caracter inesperado' do
        expect { Scanner.new('@').scan }.to raise_error(Scanner::Error, 'Unexpected character: @')
      end
    end
  end
end
