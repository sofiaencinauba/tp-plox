require 'stringio'
require_relative '../../src/main'

Given('the resolver program {string}') do |source|
  @resolver_source = source
end

When('the resolver runs the program') do
  @rlox = Rlox.new
  @rlox.mode = :resolve
  @resolver_stdout = StringIO.new
  @resolver_stderr = StringIO.new
  previous_stdout = $stdout
  previous_stderr = $stderr
  $stdout = @resolver_stdout
  $stderr = @resolver_stderr
  @rlox.run(@resolver_source)
ensure
  $stdout = previous_stdout
  $stderr = previous_stderr
end

Then('the resolver should report success') do
  expect(@resolver_stdout.string).to eq("Resolución completada con éxito.\n")
end

Then('the resolver should report the error {string}') do |message|
  expect(@resolver_stderr.string).to include(message)
end
