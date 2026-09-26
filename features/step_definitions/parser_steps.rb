require_relative '../../src/scanner'
require_relative '../../src/parser'
require_relative '../../src/interpreter'
require_relative '../../src/resolver'

Given(/^the input "([^"]*)"$/) do |input|
    @input = input
end

When(/^I parse the expression$/) do
    @rlox = Rlox.new
    @rlox.mode = :parsing
    @result = @rlox.run(@input)
end

Then('the result should be {string}') do |expected|
    expect(@result).to eq(expected)
end

Then(/^an error should be raised$/) do
    expect { @parser.parse }.to raise_error
end

Then('an error should be raised with message {string}') do |string|
   expect { @rlox.run(@input) }
    .to output("Parsing Error: Se esperaba una expresión, se encontró semicolon.\n").to_stderr
end
