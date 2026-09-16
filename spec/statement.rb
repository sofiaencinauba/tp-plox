require 'spec_helper'
require_relative '../src/statement'

RSpec.describe Statement do
  describe 'var declaration' do
    it 'creates a variable declaration statement' do
      var_decl = VarDeclarationStatement.new('x', AST::Literal.new(5))
      expect(var_decl.name).to eq('x')
      expect(var_decl.initializer).to be_a(AST::Literal)
      expect(var_decl.initializer.value).to eq(5)
    end
  end
  describe 'function declaration' do
    it 'creates a function declaration statement' do
      func_decl = FunctionDeclaration.new('myFunc', %w[a b], [AST::Literal.new(1)])
      expect(func_decl.name).to eq('myFunc')
      expect(func_decl.params).to eq(%w[a b])
      expect(func_decl.body).to be_an(Array)
      expect(func_decl.body.first).to be_a(AST::Literal)
      expect(func_decl.body.first.value).to eq(1)
    end
  end
  describe 'expression statement' do
    it 'creates an expression statement' do
      expr_stmt = ExpressionStatement.new(AST::Literal.new(10))
      expect(expr_stmt.expression).to be_a(AST::Literal)
      expect(expr_stmt.expression.value).to eq(10)
    end
  end
  describe 'print statement' do
    it 'creates a print statement' do
      print_stmt = PrintStatement.new(AST::Literal.new('Hello'))
      expect(print_stmt.expression).to be_a(AST::Literal)
      expect(print_stmt.expression.value).to eq('Hello')
    end
  end
  describe 'block statement' do
    it 'creates a block statement' do
      block_stmt = BlockStatement.new([AST::Literal.new(1), AST::Literal.new(2)])
      expect(block_stmt.statements).to be_an(Array)
      expect(block_stmt.statements.size).to eq(2)
      expect(block_stmt.statements.first).to be_a(AST::Literal)
      expect(block_stmt.statements.first.value).to eq(1)
    end
  end
  describe 'return statement' do
    it 'creates a return statement' do
      return_stmt = ReturnStatement.new(AST::Literal.new(42))
      expect(return_stmt.value).to be_a(AST::Literal)
      expect(return_stmt.value.value).to eq(42)
    end
  end
  describe 'if statement' do
    it 'creates an if statement' do
      if_stmt = IfStatement.new(AST::Literal.new(true), AST::Literal.new('then'), AST::Literal.new('else'))
      expect(if_stmt.condition).to be_a(AST::Literal)
      expect(if_stmt.condition.value).to eq(true)
      expect(if_stmt.then_branch).to be_a(AST::Literal)
      expect(if_stmt.then_branch.value).to eq('then')
      expect(if_stmt.else_branch).to be_a(AST::Literal)
      expect(if_stmt.else_branch.value).to eq('else')
    end
  end
end
