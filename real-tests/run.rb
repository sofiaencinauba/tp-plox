# frozen_string_literal: true

require 'open3'
require 'rbconfig'

programs = Dir[File.join(__dir__, '*.lox')].sort
interpreter = File.expand_path('../src/main.rb', __dir__)

abort 'No se encontraron archivos .lox en real-tests/' if programs.empty?

programs.each do |program|
  puts "Ejecutando #{File.basename(program)}"

  stdout, stderr, status = Open3.capture3(
    RbConfig.ruby, interpreter, program, stdin_data: ''
  )

  puts stdout unless stdout.empty?
  warn stderr unless stderr.empty?

  unless status.success? && stderr.empty? &&
         !stdout.match?(/error/i) && stdout.lines.any? { |line| line.strip == 'OK' }
    abort "ERROR: falló #{File.basename(program)} (código de salida: #{status.exitstatus})."
  end

  puts
end

puts "Todo OK: #{programs.length} archivos ejecutados."
