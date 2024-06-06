# frozen_string_literal: true

class Runner
  def self.run
    runner = new
    runner.connect_manager
    runner.manager.execute('nitrogen --restore')
    runner.run
    runner.terminate
  end

  attr_reader :actions, :manager

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

  def connect_manager
    @manager.connect
  end

  def run
    @manager.handle_next_event until stopped?
  end

  def terminate
    @manager.disconnect
  end

  def kill_current
    return unless @layout.current_client

    @layout.current_client.kill
  end
end
