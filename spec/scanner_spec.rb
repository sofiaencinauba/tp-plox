require 'spec_helper'
require_relative '../src/scanner'
require_relative '../src/token'

RSpec.describe Scanner do
  def token(type, lexeme, literal = nil)
    be_a(Token).and(have_attributes(token_type: type, lexeme: lexeme, literal: literal))
  end

  describe '#scan' do
    describe 'scan_single_token' do
      it 'devuelve EOF para una fuente vacía' do
        expect(Scanner.new('').scan).to match([token(:eof, '')])
      end
      it 'devuelve un signo de exclamación para una fuente con signo de exclamación' do
        expect(Scanner.new('!').scan).to match([token(:bang, '!'), token(:eof, '')])
      end
      it 'devuelve un parentesis derecho para una fuente con parentesis derecho' do
        expect(Scanner.new(')').scan).to match([token(:right_paren, ')'), token(:eof, '')])
      end
      it 'devuelve un punto y coma para una fuente con punto y coma' do
        expect(Scanner.new(';').scan).to match([token(:semicolon, ';'), token(:eof, '')])
      end
    end

    describe 'scan_digit' do
      it 'devuelve un número para una fuente con un número' do
        expect(Scanner.new('1').scan).to match([token(:number, '1', 1), token(:eof, '')])
      end
      it 'devuelve un numero de 3 digitos para una fuente con numero de 3 digitos' do
        expect(Scanner.new('123').scan).to match([token(:number, '123', 123), token(:eof, '')])
      end
      it 'devuelve un numero flotante para una fuente con numero flotante' do
        expect(Scanner.new('123.15').scan).to match([token(:number, '123.15', 123.15), token(:eof, '')])
      end
      it 'lanza un error para un número con más de un punto decimal' do
        expect { Scanner.new('123.10.15').scan }.to raise_error(Scanner::Error, 'Invalid number: 123.10.')
      end
    end

    describe 'scan_double_token' do
      it 'devuelve un signo de desigualdad para una fuente con signo de desigualdad' do
        expect(Scanner.new('!=').scan).to match([token(:bang_equal, '!='), token(:eof, '')])
      end
      it 'devuelve un signo de igualdad para una fuente con signo de igualdad' do
        expect(Scanner.new('==').scan).to match([token(:equal_equal, '=='), token(:eof, '')])
      end
      it 'devuelve un signo de menor o igual para una fuente con signo de menor o igual' do
        expect(Scanner.new('<=').scan).to match([token(:less_equal, '<='), token(:eof, '')])
      end
      it 'devuelve un signo de mayor o igual para una fuente con signo de mayor o igual' do
        expect(Scanner.new('>=').scan).to match([token(:greater_equal, '>='), token(:eof, '')])
      end
    end

    describe 'scan_string' do
      it 'devuelve un string para una fuente con un string' do
        expect(Scanner.new('"hola"').scan).to match([token(:string, '"hola"', 'hola'), token(:eof, '')])
      end
      it 'devuelve un error para fuente con string incompleto' do
        expect { Scanner.new('"hola').scan }.to raise_error(Scanner::Error, 'Unterminated string.')
      end
    end

    describe 'scan_identifier' do
      it 'devuelve un identificador para una fuente con string no reservado' do
        expect(Scanner.new('x').scan).to match([token(:identifier, 'x'), token(:eof, '')])
      end
      it 'devuelve un identificador para una fuente con string no reservado' do
        expect(Scanner.new('xyz').scan).to match([token(:identifier, 'xyz'), token(:eof, '')])
      end
      it 'devuelve un identificador para una fuente con string no reservado' do
        expect(Scanner.new('xyz1').scan).to match([token(:identifier, 'xyz1'), token(:eof, '')])
      end
      it 'devuelve un identificador para una fuente con string no reservado' do
        expect(Scanner.new('x_yz').scan).to match([token(:identifier, 'x_yz'), token(:eof, '')])
      end
      it 'separa un identificador, un punto y un número' do
        expected_tokens = [
          token(:identifier, 'hola'),
          token(:dot, '.'),
          token(:number, '1', 1),
          token(:eof, '')
        ]

        expect(Scanner.new('hola.1').scan).to match(expected_tokens)
      end
    end
    describe 'scan_comments' do
      it 'devuelve un slash para una fuente con un slash' do
        expect(Scanner.new('/').scan).to match([token(:slash, '/'), token(:eof, '')])
      end
      it 'ignora la linea para una fuente con unica linea de comentario' do
        expect(Scanner.new('//').scan).to match([token(:eof, '')])
      end
      it 'ignora la linea para una fuente con unica linea de comentario' do
        expect(Scanner.new('//hola').scan).to match([token(:eof, '')])
      end
    end
    describe 'scan_keywords' do
      it 'devuelve una keyword para una fuente con un string keyword' do
        expect(Scanner.new('and').scan).to match([token(:and, 'and'), token(:eof, '')])
      end
      it 'devuelve una keyword para una fuente con un string keyword' do
        expect(Scanner.new('or').scan).to match([token(:or, 'or'), token(:eof, '')])
      end
      it 'no devuelve keyword para una fuente con un string keyword en mayuscula' do
        expect(Scanner.new('AND').scan).to match([token(:identifier, 'AND'), token(:eof, '')])
      end
    end
    describe 'scan_unexpected_character' do
      it 'lanza un error para una fuente con un caracter inesperado' do
        expect { Scanner.new('@').scan }.to raise_error(Scanner::Error, 'Unexpected character: @')
      end
    end
  end
end
