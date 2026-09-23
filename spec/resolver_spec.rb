require 'spec_helper'
require_relative '../src/scanner'
require_relative '../src/parser'
require_relative '../src/resolver'

RSpec.describe Resolver do
  def resolve_source(source)
    program = Parser.new(Scanner.new(source).scan).parse

    described_class.new(nil).resolve(program)
  end

  describe '#resolve' do
    it 'permite leer una variable de un scope exterior en un inicializador' do
      expect do
        resolve_source('var a = "global"; { var b = a; };')
      end.not_to raise_error
    end

    it 'rechaza leer una variable local en su propio inicializador' do
      expect do
        resolve_source('{ var a = a; };')
      end.to raise_error(Resolver::Error, /propio inicializador/)
    end

    it 'cierra el scope de cada bloque' do
      expect do
        resolve_source('{ var a = 1; }; { var a = a; };')
      end.to raise_error(Resolver::Error, /propio inicializador/)
    end

    it 'resuelve las ramas de un if' do
      expect do
        resolve_source('if (true) { var a = a; } else { print "ok"; };')
      end.to raise_error(Resolver::Error, /propio inicializador/)
    end

    it 'resuelve el cuerpo de un while' do
      expect do
        resolve_source('while (true) { var a = a; };')
      end.to raise_error(Resolver::Error, /propio inicializador/)
    end

    it 'mantiene el scope del for al resolver un cuerpo sin bloque' do
      expect do
        resolve_source('for (var i = 0; i < 1; i = i + 1) var a = a;')
      end.to raise_error(Resolver::Error, /propio inicializador/)
    end
  end
end
