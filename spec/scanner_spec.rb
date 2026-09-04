require 'spec_helper'
require_relative '../src/scanner'

RSpec.describe Scanner do
  describe '#scan' do
    it 'devuelve una lista vacía para una fuente vacía' do
      expect(Scanner.new('').scan).to eq([])
    end
    it 'devuelve un parentesis izquierdo para una fuente con parentesis izquierdo' do
      expect(Scanner.new('(').scan).to eq([{ type: :left_paren }])
    end
    it 'devuelve un parentesis derecho para una fuente con parentesis derecho' do
      expect(Scanner.new(')').scan).to eq([{ type: :right_paren }])
    end
    it 'devuelve un punto y coma para una fuente con punto y coma' do
      expect(Scanner.new(';').scan).to eq([{ type: :semicolon }])
    end
  end
end
