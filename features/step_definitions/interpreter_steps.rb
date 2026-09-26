require 'stringio'
require_relative '../../src/main'

Given('the interpreter program {string}') do |source|
  @interpreter_source = source
end

When('the interpreter runs the program') do
  @rlox = Rlox.new
  output = StringIO.new
  previous_stdout = $stdout
  $stdout = output
  @rlox.run(@interpreter_source)
  @interpreter_output = output.string
ensure
  $stdout = previous_stdout
end

Then('the interpreter output should be:') do |expected|
  expect(@interpreter_output).to eq(expected)
end
