require 'csv'
require 'fileutils'
require 'open3'

ROOT = File.expand_path('..', __dir__)
PROGRAMS = Dir[File.join(ROOT, 'real-tests', '*.lox')].sort.freeze
COMMAND = ['ruby', File.join(ROOT, 'src', 'main.rb')].freeze
RESULTS = File.join(__dir__, 'results_ruby.csv')
REPETITIONS = 10
WARMUPS = 2

abort 'No se encontraron archivos .lox en real-tests/' if PROGRAMS.empty?

def measure(program)
  start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  stdout, stderr, status = Open3.capture3(*COMMAND, program, stdin_data: '')
  elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

  unless status.success? && stderr.empty? && stdout.lines.any? { |line| line.strip == 'OK' } &&
         !stdout.match?(/error/i)
    raise "Falló #{File.basename(program)}: stdout=#{stdout.inspect}, stderr=#{stderr.inspect}, exit=#{status.exitstatus}"
  end

  elapsed
end

samples = {}

PROGRAMS.each do |program|
  WARMUPS.times { measure(program) }
  samples[File.basename(program)] = Array.new(REPETITIONS) { measure(program) }
end

FileUtils.mkdir_p(File.dirname(RESULTS))
CSV.open(RESULTS, 'w') do |csv|
  csv << %w[implementation benchmark iteration seconds]
  samples.each do |benchmark, times|
    times.each_with_index { |seconds, index| csv << ['ruby', benchmark, index + 1, seconds] }
  end

  csv << []
  csv << %w[implementation benchmark minimum_seconds mean_seconds maximum_seconds]
  samples.each do |benchmark, times|
    csv << ['ruby', benchmark, times.min, times.sum / times.length.to_f, times.max]
  end
end
puts "Resultados guardados en #{RESULTS}"
