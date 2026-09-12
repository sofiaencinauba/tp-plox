require_relative 'token'
require_relative 'node'

class Env
  class Error < StandardError; end

  def initialize(enclosing = nil)
    @values = {}
    @enclosing = enclosing
  end

  def define(name, value)
    @values[name] = value
  end

  def get(name)
    return @values[name] if @values.key?(name)
    return @enclosing.get(name) if @enclosing
    
    raise Error, "Variable '#{name}' no definida."
  end

  def assign(name, value)
    if @values.key?(name)
      @values[name] = value
      return value
    end

    return @enclosing.assign(name, value) if @enclosing
    
    raise Error, "Variable '#{name}' no definida."
  end
end