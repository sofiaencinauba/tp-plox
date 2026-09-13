require_relative 'scanner'
require_relative 'parser'
require_relative 'interpreter'

class Rlox
  attr_accessor :mode

  def initialize
    @mode = nil
    @interpreter = Interpreter.new
  end

  def run(source)
    scanner = Scanner.new(source)
    tokens = scanner.scan

    if @mode == :scanning
      tokens.each do |token|
        puts token.inspect unless token.nil?
      end
      return
    end
    
    parser = Parser.new(tokens)
    statements = parser.parse

    if @mode == :parsing
        puts ASTPrinter.new.print(statements)
        return
    end

    @interpreter.interpret(statements)
    rescue Scanner::Error => e
        puts "Scanning Error: #{e}"
    rescue Parser::Error => e
        puts "Parsing Error: #{e}"
    rescue Interpreter::Error => e
        puts "Runtime Error: #{e}"
    end
  
end

rlox = Rlox.new

if ARGV.include?('--scanning')
  rlox.mode = :scanning
elsif ARGV.include?('--parsing')
  rlox.mode = :parsing
end

loop do
  print "> "
  source = STDIN.gets

  break if source.nil?

  rlox.run(source)
end