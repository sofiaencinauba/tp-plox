require 'spec_helper'
require_relative '../src/token'

RSpec.describe Token do
  describe '#inspect' do
    it 'muestra el tipo de un token sin literal' do
      expect(Token.new(TokenType::PLUS).inspect).to eq('plus')
    end

    it 'muestra el literal cuando el token lo tiene' do
      expect(Token.new(TokenType::NUMBER, nil, 42).inspect).to eq('number<42>')
    end

    it 'muestra el lexema de un identificador' do
      expect(Token.new(TokenType::IDENTIFIER, 'contador').inspect).to eq('identifier<contador>')
    end
  end
end