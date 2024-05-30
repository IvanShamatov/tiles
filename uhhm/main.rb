# frozen_string_literal: true

require 'uh'
require 'runner'
require 'x_event_logger'
require 'dispatcher'
require 'manager'
require 'events'

require 'client'

OtherWMRunningError = Class.new(RuntimeError)

Runner.run(Config.new)
