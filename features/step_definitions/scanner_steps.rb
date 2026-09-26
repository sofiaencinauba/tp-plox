require_relative '../../src/main'

Given('the source code is:') do |input|
    @input = input
end

When('the scanner is run') do
  @rlox = Rlox.new
  @rlox.mode = :scanning
  @tokens = @rlox.run(@input)
end

Then('the following tokens should be produced:') do |table|
    expected_tokens = table.hashes
    actual_tokens = @tokens.reject { |token| token.token_type == TokenType::EOF }

    expect(actual_tokens.map { |token| [token.token_type.to_s.upcase, token.lexeme] })
      .to eq(expected_tokens.map { |token| [token['Token Type'], token['Lexeme']] })
end

Then('an error should be raised indicating an invalid token was encountered') do
  expect { @rlox.run(@input) }
    .to output("Scanning Error: Unexpected character: @\n").to_stderr
end