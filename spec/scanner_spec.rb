require 'spec_helper'
require_relative '../src/scanner'

RSpec.describe Scanner do
  describe '#scan' do
    describe 'scan_single_token' do
      it 'devuelve una lista vacía para una fuente vacía' do
        expect(Scanner.new('').scan).to eq([])
      end
      it 'devuelve un signo de exclamación para una fuente con signo de exclamación' do
        expect(Scanner.new('!').scan).to eq([{ type: :bang, lexeme: nil }])
      end
      it 'devuelve un parentesis derecho para una fuente con parentesis derecho' do
        expect(Scanner.new(')').scan).to eq([{ type: :right_paren, lexeme: nil }])
      end
      it 'devuelve un punto y coma para una fuente con punto y coma' do
        expect(Scanner.new(';').scan).to eq([{ type: :semicolon, lexeme: nil }])
      end
    end

    describe 'scan_digit' do
      it 'devuelve un número para una fuente con un número' do
        expect(Scanner.new('1').scan).to eq([{ type: :number, lexeme: "1" }])
      end
      it 'devuelve un numero de 3 digitos para una fuente con numero de 3 digitos' do
        expect(Scanner.new('123').scan).to eq([{ type: :number, lexeme: "123"}])
      end
    end

    describe 'scan_double_token' do
      it 'devuelve un signo de desigualdad para una fuente con signo de desigualdad' do
        expect(Scanner.new('!=').scan).to eq([{ type: :bang_equal, lexeme: nil }])
      end
      it 'devuelve un signo de igualdad para una fuente con signo de igualdad' do
        expect(Scanner.new('==').scan).to eq([{ type: :equal_equal, lexeme: nil }])
      end
      it 'devuelve un signo de menor o igual para una fuente con signo de menor o igual' do
        expect(Scanner.new('<=').scan).to eq([{ type: :less_equal, lexeme: nil }])
      end
      it 'devuelve un signo de mayor o igual para una fuente con signo de mayor o igual' do
        expect(Scanner.new('>=').scan).to eq([{ type: :greater_equal, lexeme: nil }])
      end
    end

    describe 'scan_string' do
      it 'devuelve un string para una fuente con un string' do
        expect(Scanner.new('"hola"').scan).to eq([{ type: :string, lexeme: 'hola' }])
      end
    end
    
    describe 'scan_unexpected_character' do
      it 'lanza un error para una fuente con un caracter inesperado' do
        expect { Scanner.new('@').scan }.to raise_error(Scanner::Error, 'Unexpected character: @')
      end
    end
  end
end
