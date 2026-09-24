

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
			resolve_local(node, node.name)

		when AST::ExpressionStatement
			resolve(node.expression)

		when AST::IfStatement
			resolve(node.condition)
			resolve(node.then_branch)
			resolve(node.else_branch) if node.else_branch

		when AST::WhileStatement
			resolve(node.condition)
			resolve(node.body)

		when AST::ForStatement
		begin
			begin_scope
			resolve(node.initializer) if node.initializer
			resolve(node.condition) if node.condition
			resolve(node.increment) if node.increment
			resolve(node.body)
		ensure
			end_scope
		end

		when AST::PrintStatement
			resolve(node.expression)

		when AST::Binary, AST::Logical
			resolve(node.left)
			resolve(node.right)

		when AST::Unary
			resolve(node.right)

		when AST::Grouping
			resolve(node.expression)

		when AST::Call
			resolve(node.callee)
			node.arguments.each { |arg| resolve(arg) }

		when AST::FunctionDeclaration
			declare(node.name.lexeme)
			define(node.name.lexeme)

		begin
			begin_scope
			node.params.each do |param|
				declare(param.lexeme)
				define(param.lexeme)
			end
			resolve(node.body)
		ensure
			end_scope
		end

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
		resolve_local(expression, expression.name)
	end

	def resolve_local(node, name)
		@scopes.reverse_each.with_index do |scope, distance|
			next unless scope.key?(name)

			@interpreter.resolve(node, distance)
			return
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