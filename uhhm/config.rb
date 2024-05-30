class Config
  attr_reader :keybinds, :modifier, :layout

  def initialize
    @modifier = :mod1
    @keybinds = {
      [:q, :shift] => proc { quit },
      [:p]         => proc { execute 'dmenu_run -b' }
      [:enter]     => proc { execute 'kitty' }
    }.freeze
  end

  def logger
    @logger ||= Logger.new
  end
end
