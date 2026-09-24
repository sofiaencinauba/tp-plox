require_relative 'token'
require_relative 'ast_node'

class Env
  class Error < StandardError; end
  
  attr_reader :enclosing
  def initialize(enclosing = nil)
    @values = {}
    @enclosing = enclosing
  end

  def define(name, value)
    @values[name] = value
  end

  def ancestor(distance)
    environment = self
    distance.times { environment = environment.enclosing }
    environment
  end

  def get_at(distance, name)
    ancestor(distance).get(name)
  end

  def assign_at(distance, name, value)
    ancestor(distance).assign(name, value)
  end

  def get(name)
    return @values[name] if @values.key?(name)

    raise Error, "Variable '#{name}' no definida."
  end

  def assign(name, value)
    raise Error, "Variable '#{name}' no definida." unless @values.key?(name)

    @values[name] = value
  end

end
