require 'spec_helper'
require_relative '../src/scanner'
require_relative '../src/parser'

RSpec.describe Parser do
  def parse(source)
    Parser.new(Scanner.new(source).scan).parse
  end

  it 'parsea un número como literal' do
    expect(parse('1')).to eq(AST::Literal.new(1.0))
  end
end