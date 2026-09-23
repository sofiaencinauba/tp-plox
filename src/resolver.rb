

class Resolver
  class Error < StandardError; end

  def initialize(_interpreter)
    @scopes = []
  end

	def resolve(node)
		case node
		when AST::Program
			node.statements.each { |statement| resolve(statement) }

		when AST::BlockStatement
			resolve_block(node)

		when AST::VarDeclaration
			resolve_var_declaration(node)

		when AST::Variable
			resolve_variable(node)

		when AST::Assignment
			resolve(node.value)
		end
	end

	def resolve_block(block)
		begin_scope
		block.statements.each { |statement| resolve(statement) }
	ensure
		end_scope
	end

	def resolve_var_declaration(statement)
		name = statement.name.lexeme

		declare(name)
		resolve(statement.initializer) if statement.initializer
		define(name)
	end

	def resolve_variable(expression)
		if !@scopes.empty? && @scopes.last[expression.name] == :declared
			raise Error, "No se puede leer '#{expression.name}' en su propio inicializador."
		end
	end

	def begin_scope
		@scopes << {}
	end

	def end_scope
		@scopes.pop
	end

	def declare(name)
		return if @scopes.empty?

		raise Error, "La variable '#{name}' ya existe en este scope." if @scopes.last.key?(name)

		@scopes.last[name] = :declared
	end

	def define(name)
		return if @scopes.empty?

		@scopes.last[name] = :defined
	end
  
end