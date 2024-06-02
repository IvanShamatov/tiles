# frozen_string_literal: true

class Runner
  def self.run
    runner = new
    runner.register_event_hooks
    runner.connect_manager
    runner.run
    runner.terminate
  end

  attr_reader :actions

  def initialize
    @manager = Manager.new(@modifier, @layout)
    @stopped = false
  end

  def config
    @modifier = :mod1
    @keybinds = {
      %i[q shift] => proc { stop! },
      # [:p]         => proc { execute 'dmenu_run -b' },
      # [:enter]     => proc { execute 'kitty' },
      [:left] => proc { puts 'focus previous' },
      [:right] => proc { puts 'focus next' },
      [:up] => proc { puts 'swap previous' },
      [:down] => proc { puts 'swap next' },
      [:d] => proc { puts 'delete window' },
      [:l] => proc { puts 'next layout' }
    }.freeze
  end

  def logger
    @logger ||= Logger.new
  end

  def stopped?
    !!@stopped
  end

  def stop!
    @stopped = true
  end

  def register_event_hooks
    @keybinds.each do |keysym, command|
      @dispatcher.on(:key, *keysym) { evaluate(command) }
    end
  end

  def connect_manager
    manager.connect
    @keybinds.each_key { |keysym| manager.grab_key(*keysym) }
  end

  def run
    manager.handle_next_event until stopped?
  end

  def terminate
    manager.disconnect
  end

  def evaluate(code = nil, &block)
    if code
      instance_exec(&code)
    else
      instance_exec(&block)
    end
  end

  def execute(command)
    log "Execute: #{command}"
    pid = fork do
      fork do
        Process.setsid
        begin
          exec command
        rescue Errno::ENOENT => e
          log_error "ExecuteError: #{e}"
        end
      end
    end
    Process.waitpid pid
  end

  def kill_current
    return unless layout.current_client

    layout.current_client.kill
  end
end
