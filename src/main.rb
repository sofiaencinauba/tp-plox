require 'reline'
require 'fileutils'
require_relative 'scanner'
require_relative 'parser'
require_relative 'resolver'
require_relative 'interpreter'
require_relative 'terminal_colors'

class Rlox
  HISTORY_FILE = File.join(Dir.home, '.rlox_history')

  attr_accessor :mode, :debug

  def initialize
    @mode = nil
    @debug = false
    @interpreter = Interpreter.new
    @resolver = Resolver.new(@interpreter)
  end

  def run(source, display_result: false)
    scanner = Scanner.new(source)
    tokens = scanner.scan

    if @mode == :scanning
      tokens.each do |token|
        puts TerminalColors.colorize(token.inspect, :cyan) unless token.nil?
      end
      return tokens
    end

    parser = Parser.new(tokens)
    program = parser.parse

    if @mode == :parsing
      program.statements.each do |statement|
        puts TerminalColors.colorize(statement.inspect, :cyan)
      end
      return
    end

    if @mode == :resolve
      @resolver.resolve(program)
      puts TerminalColors.colorize("Resolución completada con éxito.", :green)
      return
    end

    @resolver.resolve(program)

    result = @interpreter.interpret(program)
    puts result if display_result && program.statements.last.is_a?(AST::ExpressionStatement)
    result
  rescue Scanner::Error => e
    report_error('Scanning', e)
  rescue Parser::Error => e
    report_error('Parsing', e)
  rescue Interpreter::Error => e
    report_error('Runtime', e)
  rescue Resolver::Error => e
    report_error('Resolver', e)
  rescue Env::Error => e
    report_error('Environment', e)
  end

  def main
    args = ARGV.dup

    # True si se pasa el argumento --debug, y lo elimina de la lista de argumentos
    @debug = !!args.delete('--debug')

    modes = {
      '--scanning' => :scanning,
      '--parsing' => :parsing,
      '--resolve' => :resolve
    }

    selected_modes = modes.keys & args

    if selected_modes.length > 1
      warn 'Error: No se puede usar múltiples modos simultáneamente.'
      exit 1
    end

    unless selected_modes.empty?
      flag = selected_modes.first
      @mode = modes[flag]
      args.delete(flag)
    end

    line_by_line = !!args.delete('--line-by-line')

    if args.length > 1
      warn 'Uso: ruby main.rb [options] [file]'
      exit 1
    end

    if args.empty?
      run_prompt
    else
      run_file(args.first, line_by_line: line_by_line)
    end
  end

  private

  def report_error(phase, error)
    message = "#{phase} Error: #{error.message}"

    warn TerminalColors.colorize(message, :red, io: $stderr)

    return unless @debug

    warn error.full_message(highlight: $stderr.tty?)
  end

  def run_file(path, line_by_line: false)
    unless File.file?(path)
      warn "Archivo no encontrado: #{path}"
      exit 1
    end

    if line_by_line
      File.foreach(path) do |line|
        puts "> #{line.chomp}"
        run(line)
      end
    else
      run(File.read(path))
    end
  end

  def run_prompt
    load_history

    loop do
      source = Reline.readline('> ', true)

      break if source.nil?

      unless source.strip.empty?
        run(source, display_result: true)
      end
    end
  rescue Interrupt
    puts
  ensure
    save_history
  end

  def load_history
    return unless File.file?(HISTORY_FILE)

    File.foreach(HISTORY_FILE, chomp: true) do |line|
      Reline::HISTORY << line
    end
  end

  def save_history
    FileUtils.mkdir_p(File.dirname(HISTORY_FILE))

    File.write(
      HISTORY_FILE,
      Reline::HISTORY.to_a.join("\n") + "\n"
    )
  end
end

Rlox.new.main if __FILE__ == $PROGRAM_NAME
