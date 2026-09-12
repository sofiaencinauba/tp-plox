require 'spec_helper'
require_relative '../src/env'

RSpec.describe Env do
  let(:env) { described_class.new }

  describe '#define y #get' do
    it 'define y recupera una variable' do
      env.define('nombre', 'Lox')

      expect(env.get('nombre')).to eq('Lox')
    end

    it 'permite definir una variable con valor nil' do
      env.define('vacio', nil)

      expect(env.get('vacio')).to be_nil
    end

    it 'falla al obtener una variable no definida' do
      expect { env.get('inexistente') }
        .to raise_error(Env::Error, "Variable 'inexistente' no definida.")
    end
  end

  describe '#assign' do
    it 'actualiza una variable existente' do
      env.define('numero', 1)

      expect(env.assign('numero', 2)).to eq(2)
      expect(env.get('numero')).to eq(2)
    end

    it 'falla al asignar una variable no definida' do
      expect { env.assign('inexistente', 1) }
        .to raise_error(Env::Error, "Variable 'inexistente' no definida.")
    end
  end

  describe 'entornos anidados' do
    let(:parent) { described_class.new }
    let(:child) { described_class.new(parent) }

    it 'obtiene una variable del entorno padre' do
      parent.define('global', 1)

      expect(child.get('global')).to eq(1)
    end

    it 'asigna una variable existente del entorno padre' do
      parent.define('global', 1)

      child.assign('global', 2)

      expect(parent.get('global')).to eq(2)
    end
  end
end
