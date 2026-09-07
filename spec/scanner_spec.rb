require 'spec_helper'
require_relative '../src/scanner'

RSpec.describe Scanner do
  describe '#scan' do
    describe 'scan_single_token' do
      it 'devuelve una lista vacía para una fuente vacía' do
        expect(Scanner.new('').scan).to eq([])
      end
      it 'devuelve un signo de exclamación para una fuente con signo de exclamación' do
        expect(Scanner.new('!').scan).to eq([{ type: :bang }])
      end
      it 'devuelve un parentesis derecho para una fuente con parentesis derecho' do
        expect(Scanner.new(')').scan).to eq([{ type: :right_paren }])
      end
      it 'devuelve un punto y coma para una fuente con punto y coma' do
        expect(Scanner.new(';').scan).to eq([{ type: :semicolon }])
      end
    end

    describe 'scan_digit' do
      it 'devuelve un número para una fuente con un número' do
        expect(Scanner.new('1').scan).to eq([{ type: :number }])
      end
    end

    describe 'scan_double_token' do
      it 'devuelve un signo de desigualdad para una fuente con signo de desigualdad' do
        expect(Scanner.new('!=').scan).to eq([{ type: :bang_equal }])
      end
      it 'devuelve un signo de igualdad para una fuente con signo de igualdad' do
        expect(Scanner.new('==').scan).to eq([{ type: :equal_equal }])
      end
      it 'devuelve un signo de menor o igual para una fuente con signo de menor o igual' do
        expect(Scanner.new('<=').scan).to eq([{ type: :less_equal }])
      end
      it 'devuelve un signo de mayor o igual para una fuente con signo de mayor o igual' do
        expect(Scanner.new('>=').scan).to eq([{ type: :greater_equal }])
      end
    end

    describe 'scan_unexpected_character' do
      it 'lanza un error para una fuente con un caracter inesperado' do
        expect { Scanner.new('@').scan }.to raise_error(Scanner::Error, 'Unexpected character: @')
      end
    end
  end
end
