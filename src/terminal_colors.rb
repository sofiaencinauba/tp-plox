module TerminalColors
  COLORS = {
    red: 31,
    green: 32,
    yellow: 33,
    cyan: 36
  }.freeze

  def self.colorize(text, color, io: $stdout)
    return text unless io.tty?
    return text if ENV.key?('NO_COLOR')

    code = COLORS.fetch(color)
    "\e[#{code}m#{text}\e[0m"
  end
end