# frozen_string_literal: true

class Runner
  def self.run
    runner = new
    runner.connect_manager
    runner.execute('kitty')
    runner.run
    runner.terminate
  end

  attr_reader :actions

  def initialize
    @manager = Manager.new(self)
    @stopped = false
  end

  def stopped?
    !!@stopped
  end

  def stop!
    @stopped = true
  end

  def register_event_hooks
    @keybinds.each do |keysym, command|
      # @dispatcher.on(:key, *keysym) { evaluate(command) }
    end
  end

  def connect_manager
    @manager.connect
  end

  def run
    @manager.handle_next_event until stopped?
  end

  def terminate
    @manager.disconnect
  end

  def evaluate(code = nil, &block)
    if code
      instance_exec(&code)
    else
      instance_exec(&block)
    end
  end

  def execute(command)
    $logger.info "Execute: #{command}"
    pid = fork do
      fork do
        Process.setsid
        begin
          exec command
        rescue Errno::ENOENT => e
          $logger.info "ExecuteError: #{e}"
        end
      end
    end
    Process.waitpid pid
  end

  def kill_current
    return unless @layout.current_client

    @layout.current_client.kill
  end
end
